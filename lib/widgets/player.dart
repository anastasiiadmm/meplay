import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import '../utils/hls_video_cache.dart';
import '../video_player_fork/video_player.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../widgets/modals.dart';
import '../screens/base.dart';


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
  static const choices = [r43, r169, r1610];
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


class HLSPlayer extends StatefulWidget {
  final Channel channel;
  final void Function() toPrevChannel;
  final void Function() toNextChannel;
  final void Function() toggleFullscreen;
  final Duration controlsTimeout;
  final Duration settingsTimeout;

  @override
  HLSPlayer({
    Key key,
    this.channel,
    this.toPrevChannel,
    this.toNextChannel,
    this.toggleFullscreen,
    this.controlsTimeout: const Duration(seconds: 5),
    this.settingsTimeout: const Duration(seconds: 3),
  }): super(key: key);

  @override
  _HLSPlayerState createState() => _HLSPlayerState();
}


class _HLSPlayerState extends State<HLSPlayer> {
  VideoPlayerController _controller;
  VideoAR _ratio = VideoAR.r43;
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

  @override
  void initState() {
    super.initState();
    _initBrightness();
    if (!widget.channel.locked) {
      _loadChannel();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
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
    await _controller?.dispose();
    _cache?.clear();
  }

  Future<void> _loadChannel() async {
    _cache = HLSVideoCache(widget.channel.url);
    await _cache.load();
    if(!mounted) {
      _disposeVideo();
    } else {
      VideoPlayerController controller = VideoPlayerController.cache(_cache);
      await controller.initialize();
      if(!mounted) {
        _disposeVideo();
      } else {
        setState(() {
          _controller = controller;
          _volume = _controller.value.volume;
        });
        controller.play();
      }
    }
  }

  void _showSettings() {
    // explore this
    // showMenu({
    //
    // });
    selectorModal<VideoAR>(
      context: context,
      title: Text(
        'Стороны видео',
        textAlign: TextAlign.center,
      ),
      choices: VideoAR.choices,
      onSelect: (VideoAR value) {
        setState(() {
          _ratio = value;
        });
      },
    );
  }

  void _togglePlay() {
    if (_controller != null) {
      if (_controller.value.isPlaying) {
        setState(() {
          _controller.pause();
        });
      } else {
        setState(() {
          _controller.play();
        });
      }
    }
  }

  void _showControls() {
    _controlsTimer?.cancel();
    setState(() {
      _controlsVisible = true;
    });
    _controlsTimer = Timer(widget.controlsTimeout, _hideControls);
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() {
      _controlsVisible = false;
    });
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

  // TODO: chromecast
  // void _chromecast() {
  //   https://pub.dev/packages/flutter_video_cast/
  // }


  Widget get _scrollBar {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: _controller == null ? null : VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          backgroundColor: AppColors.transparentGray,
          playedColor: AppColors.gray5,
          bufferedColor: AppColors.gray40,
        ),
      ),
    );
  }

  void _goLive() {
    NavItems.inDevelopment(context, title: 'Эта функция');
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
    setState(() {
      _brightnessVisible = true;
    });
    _brightnessTimer = Timer(widget.settingsTimeout, _hideBrightness);
  }

  void _showVolume() {
    _volumeTimer?.cancel();
    setState(() {
      _volumeVisible = true;
    });
    _volumeTimer = Timer(widget.settingsTimeout, _hideVolume);
  }

  void _hideBrightness() {
    _brightnessTimer?.cancel();
    setState(() {
      _brightnessVisible = false;
    });
  }

  void _hideVolume() {
    _volumeTimer?.cancel();
    setState(() {
      _volumeVisible = false;
    });
  }

  Widget get _backdrop {
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0,
      duration: controlsAnimationDuration,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientTop),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientBottom),
        ),
      ),
    );
  }
  
  Widget get _controls {
    return AbsorbPointer(
      absorbing: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0,
        duration: controlsAnimationDuration,
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientTop),
          child: Container(
            decoration: BoxDecoration(gradient: AppColors.gradientBottom),
            child: Column(
              children: <Widget>[
                Padding (
                  padding: _fullscreen
                      ? EdgeInsets.fromLTRB(20, 15, 20, 0)
                      : EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: _fullscreen ? Text(
                            widget.channel.title,
                            style: AppFonts.screenTitle,
                          ) : null,
                        ),
                      ),
                      // TODO: chromecast
                      // IconButton(
                      //   icon: AppIcons.chromecast,
                      //   onPressed: _chromecast,
                      // ),
                      IconButton(
                        icon: AppIcons.settings,
                        onPressed: _showSettings,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: AppIcons.skipPrev,
                        onPressed: widget.toPrevChannel,
                        padding: EdgeInsets.zero,
                      ),
                      Container(
                        width: 56,
                        margin: EdgeInsets.all(30),
                        child: _controller == null ? null : IconButton(
                          icon: _controller != null && _controller.value.isPlaying
                              ? AppIcons.pause
                              : AppIcons.play,
                          onPressed: _togglePlay,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      IconButton(
                        icon: AppIcons.skipNext,
                        onPressed: widget.toNextChannel,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Padding (
                  padding: _fullscreen
                      ? EdgeInsets.fromLTRB(20, 0, 20, 15)
                      : EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Text(_timeDisplay, style: AppFonts.videoTimer,),
                      TextButton(
                        onPressed: _goLive,
                        child: Text('LIVE', style: AppFonts.screenTitle),
                      ),
                      Expanded(
                        child: _scrollBar,
                      ),
                      IconButton(
                        icon: _fullscreen ? AppIcons.smallScreen : AppIcons.fullScreen,
                        onPressed: _toggleFullScreen,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingControlBlock(IconData icon, String value, bool visible) {
    return AnimatedOpacity(
      opacity: _settingsVisible ? 1.0 : 0,
      duration: controlsAnimationDuration,
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(icon, color: AppColors.gray0, size: 24,),
            ),
            Text(value, style: AppFonts.videoSettingValues,),
          ],
        ),
      ),
    );
  }

  IconData get _volumeIcon {
    if(_volume == null || _volume == 0) {
      return Icons.volume_mute;
    }
    if (_volume > 0.5) {
      return Icons.volume_up;
    }
    return Icons.volume_down;
  }

  IconData get _brightnessIcon {
    if(_brightness == null || _brightness == 0) {
      return Icons.brightness_low;
    }
    if (_brightness > 0.5) {
      return Icons.brightness_high;
    }
    return Icons.brightness_medium;
  }

  Widget get _settingControls {
    return AnimatedOpacity(
      opacity: _settingsVisible ? 1.0 : 0,
      duration: controlsAnimationDuration,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientTop),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientBottom),
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
        ),
      ),
    );
  }

  Widget get _fullscreenPlayer {
    return GestureDetector(
      onTap: _toggleControls,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Material(
        color: AppColors.black,
        child: Stack(
          children: [
            Center (
              child: _controller == null
                  ? Animations.progressIndicator
                  : AspectRatio(
                aspectRatio: _ratio.value,
                child: VideoPlayer(
                  _controller,
                ),
              ),
            ),
            _controls,
            _settingControls,
          ],
        ),
      ),
    );
  }

  Widget get _adaptivePlayer {
    return GestureDetector(
      onTap: _toggleControls,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AspectRatio(
        aspectRatio: _ratio.value,
        child: Material(
          color: AppColors.black,
          child: Stack(
            children: <Widget>[
              _controller == null ? Center(
                child: Animations.progressIndicator,
              ) : VideoPlayer(
                _controller,
              ),
              _controls,
              IgnorePointer(
                child: _settingControls,
                ignoring: !_settingsVisible,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _fullscreen ? _fullscreenPlayer : _adaptivePlayer;
  }
}
