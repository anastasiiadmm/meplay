import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/hls_video_cache.dart';
import '../video_player_fork/video_player.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../screens/base.dart';


class VideoAR {
  final String name;
  final double value;

  const VideoAR(this.name, this.value);

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


class HLSPlayer extends StatefulWidget {
  final Channel channel;
  final void Function() toPrevChannel;
  final void Function() toNextChannel;
  final void Function() toggleFullscreen;
  final Duration controlsTimeout;

  @override
  HLSPlayer({
    Key key,
    this.channel,
    this.toPrevChannel,
    this.toNextChannel,
    this.toggleFullscreen,
    this.controlsTimeout: const Duration(seconds: 5),
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
  bool _settingControlsVisible = false;
  Offset _panStartPoint;
  SwipeAction _panAction;

  @override
  void initState() {
    super.initState();
    // TODO: take the real values
    _brightness = 1.0;
    _volume = 0.5;
    _settingControlsVisible = true;

    if (!widget.channel.locked) {
      _loadChannel();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    _controlsTimer?.cancel();
    super.dispose();
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
        });
        controller.play();
      }
    }
  }

  void _showSettings() {
    NavItems.inDevelopment(context, title: 'Настройки');
    // TODO: show items: change aspect ratio and favorites
    // setState(() {
    //   _aspectRatio = ratio > 0 ? ratio : _controller.value.aspectRatio;
    // });
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
    _controlsTimer = Timer(widget.controlsTimeout, _hideControls);
    setState(() {
      _controlsVisible = true;
    });
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() {
      _controlsVisible = false;
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
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

  void _onPanStart(DragStartDetails details) {
    _panStartPoint = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _detectAction(details.delta);
    if (_panAction == SwipeAction.brightness) {
      double brightness = _brightness - details.delta.dy / 200;
      if (brightness > 1) brightness = 1;
      else if (brightness < 0) brightness = 0;
      setState(() {
        _brightness = brightness;
      });
    } else if (_panAction == SwipeAction.volume) {
      double volume = _volume - details.delta.dy / 200;
      if (volume > 1) volume = 1;
      else if (volume < 0) volume = 0;
      setState(() {
        _volume = volume;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_panAction == SwipeAction.channel) {
      if(details.velocity.pixelsPerSecond.dx > 0) {
        widget.toPrevChannel();
      } else {
        widget.toNextChannel();
      }
    }
    _panAction = null;
  }

  bool get _fullscreen {
    return OrientationHelper.isFullscreen(context);
  }

  void _toggleFullScreen() {
    OrientationHelper.toggleFullscreen();
  }

  Widget get _controls {
    return AbsorbPointer(
      absorbing: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0,
        duration: Duration(milliseconds: 200),
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

  Widget get _playerSettingsControls {
    return AnimatedOpacity(
      opacity: _settingControlsVisible ? 1.0 : 0,
      duration: Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientTop),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientBottom),
          child: Row (
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Громкость",
                        style: AppFonts.videoSettingLabels,
                      ),
                      Text(
                          "${(_volume * 100).round()}%",
                        style: AppFonts.videoSettingValues,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Яркость",
                        style: AppFonts.videoSettingLabels,
                      ),
                      Text(
                        "${(_brightness * 100).round()}%",
                        style: AppFonts.videoSettingValues,
                      ),
                    ],
                  ),
                ),
              ),
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
            _playerSettingsControls,
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
              _playerSettingsControls,
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
