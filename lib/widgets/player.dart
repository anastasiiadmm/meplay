import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import '../video_player_fork/video_player.dart';
import '../utils/hls_video_cache.dart';
import '../utils/pref_helper.dart';
import '../utils/settings.dart';
import '../utils/orientation_helper.dart';
import 'rotation_loader.dart';
import 'app_icon_button.dart';
import 'circle.dart';
import 'modals.dart';
import '../models.dart';
import '../theme.dart';


class VideoAR {
  final String name;
  final double value;

  const VideoAR(this.name, this.value);

  String toString() {
    return name;
  }

  static const r43 = VideoAR('4:3', 4/3);
  static const r169 = VideoAR('16:9', 16/9);
  static const r1610 = VideoAR('16:10', 16/10);
  static const r219 = VideoAR('21:9', 64/27);
  static const choices = [r43, r169, r1610, r219];
  static const defaultRatio = r169;

  static VideoAR getByValue(double value) {
    for (VideoAR choice in choices) {
      if((choice.value - value).abs() <= 0.05) {
        return choice;
      }
    }
    return defaultRatio;
  }

  static VideoAR getByName(String name) {
    for (VideoAR choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultRatio;
  }
}


enum SwipeAction {
  channel,
  brightness,
  volume,
}


// Converts swipe pixels to settings values.
// 200 means 200px long swipe needed to fully turn setting on or off.
// Higher the value - longer the swipe.
const int swipeFactor = 200;

// Time required to show or hide controls.
const controlsAnimationDuration = Duration(milliseconds: 200);

// Hidden live buffer where "Live" button jumps.
// at least one chunk duration is recommended,
// but not greater then total chunks loaded.
const liveBuffer = Duration(seconds: M3UChunk.intDefaultDuration);

// Invisible scrollbar part where user can not seek manually.
// should be equal to live buffer size + one chunk duration,
// but not greater then total chunks loaded.
const scrollBuffer = Duration(seconds: M3UChunk.intDefaultDuration);


class HLSPlayer extends StatefulWidget {
  final Channel channel;
  final void Function() toPrevChannel;
  final void Function() toNextChannel;
  final void Function() toggleFullscreen;
  final Duration controlsTimeout;
  final Duration settingsTimeout;
  final bool pipMode;
  final double initialVolume;
  final void Function(double volume) onVolumeChange;
  final int bufferSize;

  @override
  HLSPlayer({
    Key key,
    this.channel,
    this.toPrevChannel,
    this.toNextChannel,
    this.toggleFullscreen,
    this.controlsTimeout: const Duration(seconds: 5),
    this.settingsTimeout: const Duration(seconds: 3),
    this.pipMode: false,
    this.initialVolume,
    this.onVolumeChange,
    this.bufferSize: 3,
  }): super(key: key);

  @override
  _HLSPlayerState createState() => _HLSPlayerState();
}


class _HLSPlayerState extends State<HLSPlayer> {
  VideoPlayerController _controller;
  VideoAR _ratio = VideoAR.defaultRatio;
  bool _controlsVisible = false;
  HLSVideoCache _cache;
  Timer _controlsTimer;
  double _brightness;
  double _volume;
  bool _brightnessVisible = false;
  bool _volumeVisible = false;
  Offset _panStartPoint;
  SwipeAction _panAction;
  Timer _brightnessTimer;
  Timer _volumeTimer;
  ChromeCastController _castController;

  @override
  void initState() {
    print('INIT PLAYER ${this.hashCode}');
    super.initState();
    _initBrightness();
    if(widget.channel != null) {
      if(!widget.channel.locked) _loadChannel();
      _loadRatio();
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(mounted && oldWidget.channel != widget.channel) _reload();
  }

  Future<void> _reload() async {
    await _disposeVideo();
    if(widget.channel != null) {
      if(!widget.channel.locked) _loadChannel();
      _loadRatio();
    }
  }

  @override
  void dispose() {
    print('DISPOSE PLAYER ${this.hashCode}');
    _disposeVideo();
    _disposeCast();
    _controlsTimer?.cancel();
    _brightnessTimer?.cancel();
    _volumeTimer?.cancel();
    super.dispose();
  }

  Future<void> _initBrightness() async {
    double brightness = await Screen.brightness;
    setState(() {
      _brightness = brightness;
    });
  }

  Future<void> _disposeVideo() async {
    try {
      await _controller?.dispose();
    } finally {
      _cache?.clear();
    }
  }

  Future<void> _disposeCast() async {
    await _castController?.stop();
    _castController?.removeSessionListener();
  }

  Future<void> _loadChannel() async {
    _cache = HLSVideoCache(
      widget.channel.url,
      maxInitialLoad: widget.bufferSize ~/ M3UChunk.intDefaultDuration,
    );
    await _cache.load();
    if(!mounted) _cache.clear();
    else {
      VideoPlayerController controller = VideoPlayerController.cache(_cache);
      await controller.initialize();
      if(!mounted) {
        controller.dispose();
        _cache.clear();
      } else {
        setState(() {
          _controller = controller;
        });
        if(widget.initialVolume == null) {
          setState(() {
            _volume = _controller.value.volume;
          });
        } else {
          setState(() {
            _volume = widget.initialVolume;
          });
          controller.setVolume(widget.initialVolume);
        }
        controller.play();
        _goLive();
      }
    }
  }
  
  Future<void> _loadRatio() async {
    VideoAR ratio = await PrefHelper.loadString(
      PrefKeys.ratio(widget.channel.id),
      restore: VideoAR.getByName,
      defaultValue: VideoAR.defaultRatio,
    );
    setState(() { _ratio = ratio; });
  }

  void _setRatio(VideoAR ratio) {
    setState(() { _ratio = ratio; });
    String prefKey = PrefKeys.ratio(widget.channel.id);
    PrefHelper.saveString(prefKey, _ratio);
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SelectorModal<VideoAR>(
        title: locale(context).videoAspects,
        choices: VideoAR.choices,
        onSelect: _setRatio,
        itemTitle: (ratio) => ratio.name,
        selected: _ratio,
      ),
    );
  }

  void _togglePlay() {
    if (_controller != null) {
      if (_controller.value.isPlaying) {
        setState(() { _controller.pause(); });
      } else {
        setState(() { _controller.play(); });
      }
    }
  }

  void _showControls() {
    _controlsTimer?.cancel();
    setState(() { _controlsVisible = true; });
    _controlsTimer = Timer(widget.controlsTimeout, _hideControls);
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() { _controlsVisible = false; });
  }

  void _togglePipControls() {
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  void _toggleControls() {
    if (_settingsVisible) {
      _hideVolume();
      _hideBrightness();
    } else if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  Widget get _scrollBar {
    return SizedBox(
      height: 5,
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        hiddenDuration: scrollBuffer,
        colors: VideoProgressColors(
          backgroundColor: AppColors.item,
          playedColor: AppColors.white,
          bufferedColor: AppColors.itemFocus,
        ),
        padding: EdgeInsets.only(bottom: 3),
      ),
    );
  }

  void _goLive() {
    _controller.seekTo(_controller.value.duration - liveBuffer);
  }

  void _detectAction(Offset delta) {
    if(_panAction == null) {
      if(delta.dx.abs() > delta.dy.abs()) {
        _panAction = SwipeAction.channel;
      } else {
        if(_panStartPoint.dx > MediaQuery.of(context).size.width / 2) {
          _panAction = SwipeAction.brightness;
        } else {
          _panAction = SwipeAction.volume;
        }
      }
    }
  }

  void _adjustBrightness(double delta) {
    if (_brightness != null) {
      double brightness = _brightness - delta / swipeFactor;
      brightness = brightness.clamp(0.0, 1.0);
      Screen.setBrightness(brightness);
      setState(() {
        _brightness = brightness;
      });
    }
  }

  void _adjustVolume(double delta) {
    if (_controller != null) {
      double volume = _volume - delta / swipeFactor;
      volume = volume.clamp(0.0, 1.0);
      _controller.setVolume(volume);
      if(widget.onVolumeChange != null) widget.onVolumeChange(volume);
      setState(() {
        _volume = volume;
      });
    }
  }

  void _swipeChannel(double move) {
    if(move > 0) {
      widget.toPrevChannel();
    } else {
      widget.toNextChannel();
    }
  }

  void _onPanStart(DragStartDetails details) {
    _hideControls();
    _panStartPoint = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _detectAction(details.delta);
    if (_panAction == SwipeAction.brightness) {
      _showBrightness();
      _adjustBrightness(details.delta.dy);
    } else if (_panAction == SwipeAction.volume) {
      _showVolume();
      _adjustVolume(details.delta.dy);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_panAction == SwipeAction.channel) {
      _swipeChannel(details.velocity.pixelsPerSecond.dx);
    }
    _panAction = null;
  }

  String _settingDisplay(double value, {double scale: 1.0}) {
    double percent = (value ?? 0) / scale * 100;
    return "${percent.round()}%";
  }

  bool get _fullscreen {
    return OrientationHelper.isFullscreen(context);
  }

  void _toggleFullScreen() {
    OrientationHelper.toggleFullscreen();
  }

  bool get _settingsVisible {
    return _brightnessVisible || _volumeVisible;
  }
  
  void _showBrightness() {
    _brightnessTimer?.cancel();
    setState(() { _brightnessVisible = true; });
    _brightnessTimer = Timer(widget.settingsTimeout, _hideBrightness);
  }

  void _showVolume() {
    _volumeTimer?.cancel();
    setState(() { _volumeVisible = true; });
    _volumeTimer = Timer(widget.settingsTimeout, _hideVolume);
  }

  void _hideBrightness() {
    _brightnessTimer?.cancel();
    setState(() { _brightnessVisible = false; });
  }

  void _hideVolume() {
    _volumeTimer?.cancel();
    setState(() { _volumeVisible = false; });
  }

  Widget _backdrop({Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.gradientTop),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.gradientBottom),
        child: child,
      ),
    );
  }

  Widget _animation({Widget child, bool visible}) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0,
      duration: controlsAnimationDuration,
      child: child,
    );
  }

  Widget get _controls {
    return GestureDetector(
      onTap: _toggleControls,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: _animation(
        visible: _controlsVisible || _settingsVisible,
        child: _backdrop(
          child: Stack(
            children: [
              _playerControls,
              _settingControls,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _fullscreenTitle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _fullscreen ? [
        Text(
          widget.channel.title,
          style: AppFonts.screenTitle,
          maxLines: 1,
        ),
        FutureBuilder<Program>(
          future: widget.channel.currentProgram,
          builder: (BuildContext context, snapshot) {
            return Text(
              snapshot.hasData ? snapshot.data.title : '',
              style: AppFonts.fullscreenProgram,
              maxLines: 1,
            );
          },
        ),
      ] : [],
    );
  }

  Widget get _chromeCastButton {
    return ChromeCastButton(
      size: 24,
      color: AppColors.iconColor,
      onButtonCreated: (controller) {
        setState(() => _castController = controller);
        _castController?.addSessionListener();
      },
      onSessionStarted: () {
        _castController?.loadMedia(widget.channel.url);
      },
    );
  }

  Widget get _liveButton {
    return GestureDetector(
      onTap: _goLive,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(1),
            child: Circle.dot(
              radius: 4,
              color: AppColors.red,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 2, 0, 2),
            child: Text(
              'LIVE',
              style: AppFonts.playerLive,
            ),
          )
        ]
      ),
    );
  }

  Widget get _playerControls {
    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: _animation(
        visible: _controlsVisible,
        child: Padding (
          padding: _fullscreen
              ? EdgeInsets.symmetric(vertical: 10, horizontal: 16)
              : EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _fullscreenTitle,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: _chromeCastButton,
                  ),
                  AppIconButton(
                    icon: AppIcons.cogSmall,
                    iconSize: 24,
                    onPressed: _showSettings,
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppIconButton(
                      icon: AppIcons.prev,
                      iconSize: 24,
                      onPressed: widget.toPrevChannel,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: _controller == null ? SizedBox(
                        width: 48,
                      ) : AppIconButton(
                        icon: _controller.value.isPlaying
                            ? AppIcons.pause
                            : AppIcons.play,
                        iconSize: 48,
                        onPressed: _togglePlay,
                      ),
                    ),
                    AppIconButton(
                      icon: AppIcons.next,
                      iconSize: 24,
                      onPressed: widget.toNextChannel,
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: _controller == null ? Container() : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _liveButton,
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: _scrollBar,
                        ),
                      ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: AppIconButton(
                      icon: _fullscreen
                          ? AppIcons.smallScreen
                          : AppIcons.fullScreen,
                      onPressed: _toggleFullScreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingControlBlock(IconData icon, String value, bool visible) {
    return _animation(
      visible: visible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(icon, color: AppColors.iconColor, size: 24,),
          ),
          Text(value, style: AppFonts.midText,),
        ],
      ),
    );
  }

  IconData get _volumeIcon {
    if(_volume == null || _volume == 0) return Icons.volume_mute;
    if(_volume > 0.5) return Icons.volume_up;
    return Icons.volume_down;
  }

  IconData get _brightnessIcon {
    if(_brightness == null || _brightness == 0) return Icons.brightness_low;
    if(_brightness > 0.5) return Icons.brightness_high;
    return Icons.brightness_medium;
  }

  Widget get _settingControls {
    return IgnorePointer(
      ignoring: !_settingsVisible,
      child: Row (
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _settingControlBlock(
              _volumeIcon,
              _settingDisplay(_volume),
              _volumeVisible,
            ),
          ),
          Expanded(
            child: _settingControlBlock(
              _brightnessIcon,
              _settingDisplay(_brightness),
              _brightnessVisible,
            ),
          )
        ],
      ),
    );
  }

  Widget get _lock {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blockBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: AppIcons.lockBig,
        ),
      ),
    );
  }

  Widget get _loaderBlock {
    return Center(
      child: widget.channel?.locked == true ? _lock : SizedBox(
        width: 36,
        height: 36,
        child: RotationLoader(),
      ),
    );
  }

  Widget get _fullscreenPlayer {
    return Material(
      color: AppColors.black,
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _ratio.value,
              child: _controller == null
                  ? _loaderBlock
                  : VideoPlayer(_controller),
            ),
          ),
          _controls,
        ],
      ),
    );
  }

  Widget get _adaptivePlayer {
    return AspectRatio(
      aspectRatio: _ratio.value,
      child: Material(
        color: AppColors.black,
        child: Stack(
          children: [
            _controller == null 
                ? _loaderBlock
                : VideoPlayer(_controller),
            _controls,
          ],
        ),
      ),
    );
  }

  Widget get _pipControls {
    return GestureDetector(
      onTap: _togglePipControls,
      child: _animation(
        visible: _controlsVisible,
        child: _backdrop(
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: Center(
              child: _controller == null ? null : AppIconButton(
                icon: _controller.value.isPlaying
                    ? AppIcons.pause
                    : AppIcons.play,
                onPressed: _togglePlay,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _pipModePlayer {
    return AspectRatio(
      aspectRatio: _ratio.value,
      child: Material(
        color: AppColors.black,
        child: Stack(
          children: _controller == null ? [
            _loaderBlock
          ] : [
            VideoPlayer(_controller),
            _pipControls,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pipMode) return _pipModePlayer;
    return  _fullscreen ? _fullscreenPlayer : _adaptivePlayer;
  }
}
