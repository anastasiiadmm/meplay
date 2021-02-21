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


class HLSPlayer extends StatefulWidget {
  final Channel channel;
  final Channel Function(Channel) getNextChannel;
  final Channel Function(Channel) getPrevChannel;
  final void Function(Channel) onChannelSwitch;
  final void Function() onToggleFullscreen;
  final Duration controlsTimeout;

  @override
  HLSPlayer({
    Key key,
    this.channel,
    this.getNextChannel,
    this.getPrevChannel,
    this.onChannelSwitch,
    this.onToggleFullscreen,
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
  Channel _channel;
  Channel _prevChannel;
  Channel _nextChannel;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    _prevChannel = widget.getPrevChannel(_channel);
    _nextChannel = widget.getNextChannel(_channel);
    _start();
  }

  @override
  void dispose() {
    _stop();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _start() {
    if (!_channel.locked) {
      _loadChannel();
    }
  }

  Future<void> _stop() async {
    await _controller?.dispose();
    _cache?.clear();
  }

  Future<void> _reset() async {
    await _stop();
    setState(() {
      _controller = null;
    });
    _start();
  }

  Future<void> _loadChannel() async {
    _cache = HLSVideoCache(_channel.url);
    await _cache.load();
    VideoPlayerController controller = VideoPlayerController.cache(_cache);
    await controller.initialize();
    setState(() {
      _controller = controller;
    });
    controller.play();
  }

  void _showSettings() {
    NavItems.inDevelopment(context, title: 'Настройки');
    // TODO: show items: change aspect ratio and favorites
    // setState(() {
    //   _aspectRatio = ratio > 0 ? ratio : _controller.value.aspectRatio;
    // });
  }

  void _switchPrev() async {
    _nextChannel = _channel;
    _channel = _prevChannel;
    _prevChannel = widget.getPrevChannel(_channel);
    _reset();
    widget.onChannelSwitch(_channel);
  }

  void _switchNext() async {
    _prevChannel = _channel;
    _channel = _nextChannel;
    _nextChannel = widget.getNextChannel(_channel);
    _reset();
    widget.onChannelSwitch(_channel);
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

  void _swipeBrightness() {

  }

  void _swipeVolume() {

  }

  void _swipeChannel(DragEndDetails details) {
    if(details.primaryVelocity > 0) {
      _switchPrev();
    } else {
      _switchNext();
    }
  }

  bool get _fullscreen {
    return OrientationHelper.isFullscreen(context);
  }

  void _toggleFullScreen() {
    OrientationHelper.toggleFullscreen();
  }

  Widget get _controls {
    return AnimatedOpacity(
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
                          _channel.title,
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
                      onPressed: _switchPrev,
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
                      onPressed: _switchNext,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fullscreen) {
      return  GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: AbsorbPointer(
          absorbing: !_controlsVisible,
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
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: AbsorbPointer(
          absorbing: !_controlsVisible,
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
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
