import 'dart:async';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/hls_video_cache.dart';
import '../video_player_fork/video_player.dart';
import '../models.dart';
import '../theme.dart';


const double aspectRatio43 = 4/3;
const double aspectRatio169 = 16/9;


class PlayerScreen extends StatefulWidget {
  final Channel channel;

  PlayerScreen({Key key, @required this.channel}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController _controller;
  double _aspectRatio = aspectRatio43;
  bool _controlsVisible = false;
  HLSVideoCache _cache;
  Timer _controlsTimer;
  static const Duration _controlsTimeout = Duration(seconds: 3);
  bool _fullScreen = false;

  String _timeDisplay = "00:00";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    if (!widget.channel.locked) {
      _loadVideo(widget.channel);
    }
  }

  @override
  void dispose() {
    _disposeController();
    _clearCache();
    super.dispose();
  }

  void _disposeController() {
    _controller?.dispose();
  }

  void _clearCache() {
    _cache?.clear();
  }

  void _reset() {
    _disposeController();
    _clearCache();

    setState(() {
      _controller = null;
    });
  }

  Future<void> _loadVideo(Channel channel) async {
    _reset();
    _cache = HLSVideoCache(channel.url);
    await _cache.load();
    VideoPlayerController controller = VideoPlayerController.cache(_cache);
    await controller.initialize();
    setState(() {
      _controller = controller;
      _aspectRatio ??= controller.value.aspectRatio;
    });
    controller.play();
  }

  void _changeAspectRatio(double ratio) {
    setState(() {
      _aspectRatio = ratio > 0 ? ratio : _controller.value.aspectRatio;
    });
  }

  void _openProgram() {

  }

  void _skipBack() {
    // skip to video start then prev
  }

  void _skipNext() {
    // skip to video end then next
  }

  void _openSettings() {

  }

  void _togglePlay() {
    if (!_controlsVisible) {
      _toggleControls();
    }
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
    _controlsTimer = Timer(_controlsTimeout, _hideControls);
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
    print('toggling controls');
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  void _selectAspectRatio() {

  }

  void _chromecast() {

  }

  Widget get _scrollBar {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: _controller == null ? null : VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          backgroundColor: AppColors.playBg,
          playedColor: AppColors.gray5,
          bufferedColor: AppColors.gray40,
        ),
      ),
    );
  }

  Widget get _player {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child:GestureDetector(
        onTap: _toggleControls,
        child: Material(
          color: AppColors.black,
          child: Stack(
            children: <Widget>[
              _controller == null ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray5),
                  strokeWidth: 10,
                ),
              ) : VideoPlayer(
                _controller,
              ),
              _controls,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _controls {
    List<Widget> playControls = [
      IconButton(
        icon: AppIcons.skipPrev, // TODO: if first, skip to last, other - prev
        onPressed: _skipBack,
        padding: EdgeInsets.all(0.0),
      ),
      _controller == null ? Container(
        width: 56,
      ) : IconButton(
        icon: _controller != null && _controller.value.isPlaying
          ? Icon(Icons.pause, color: AppColors.white, size: 56,)
          : AppIcons.play,
        onPressed: _togglePlay,
        padding: EdgeInsets.all(0.0),
      ),
      IconButton(
        icon: AppIcons.skipNext, // TODO: if last, skip to first, other - next
        onPressed: _skipNext,
        padding: EdgeInsets.all(0.0),
      ),
    ];
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0,
      duration: Duration(milliseconds: 200),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: _fullScreen ? Text(
                  widget.channel.name,
                  style: AppFonts.screenTitle,
                ) : Container(),
              ),
              // TODO: chromecast
              // IconButton(
              //   icon: AppIcons.chromecast,
              //   onPressed: _chromecast,
              // ),
              IconButton(
                icon: AppIcons.settings,
                onPressed: _selectAspectRatio,
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: playControls,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(_timeDisplay, style: AppFonts.videoTimer,),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              ),
              Expanded(
                child: _scrollBar,
              ),
              _fullScreen ? IconButton(
                icon: AppIcons.normalScreen,
                onPressed: _exitFullScreen,
              ) : IconButton(
                icon: AppIcons.fullScreen,
                onPressed: _enterFullScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _enterFullScreen() {
    setState(() {
      _fullScreen = true;
    });
  }

  void _exitFullScreen() {
    setState(() {
      _fullScreen = false;
    });
  }

  Future<bool> _willPop() async {
    if(_fullScreen) {
      _exitFullScreen();
      return false;
    }
    return true;
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: Text(widget.channel.name, style: AppFonts.screenTitle),
      centerTitle: true,
      actions: [
        IconButton(
          icon: AppIcons.favAdd,
          onPressed: () {_inDevelopment('Избранное');},
        ),
      ],
    );
  }

  void _inDevelopment(String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text('Находится в разработке.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Закрыть')
          )
        ],
      ),
    );
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _onNavTap(int index) {
    Navigator.of(context).pop(index);
  }

  Widget get _bottomBar {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _onNavTap,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.star,
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user,
          label: 'Профиль',
        ),
      ],
    );
  }

  Widget get _body {
    return Column(
      children: [
        _player,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBody: true,
        extendBodyBehindAppBar: false,
        appBar: _fullScreen ? null : _appBar,
        body: _body,
        bottomNavigationBar: _fullScreen ? null : _bottomBar,
      ),
    );
  }
}


// TODO: показать название канала под видео в обычном режиме
// показать замок и сделать редирект на вход, если юзера нет в sharedpreferences
// после входа кинуть на список каналов (правильно - достать каналы и нужный канал и показать всё обратно в зависимости от канала и тарифов).
// сделать переключение в фулскрин и обратно
// enable screen rotation and prev - next on swipe left - right.
// вернуть градиенты или тени под контролы.
// пофиксить ошибку aspect ration is not null и ошибку пустого контроллера при загрузке.
