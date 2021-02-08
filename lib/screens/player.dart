import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:expandable/expandable.dart';

import '../utils/hls_video_cache.dart';
import '../video_player_fork/video_player.dart';
import 'base.dart';
import '../models.dart';
import '../theme.dart';


const double aspectRatio43 = 4/3;
const double aspectRatio169 = 16/9;


class PlayerScreen extends StatefulWidget {
  final Channel channel;
  final void Function() toNext;
  final void Function() toPrev;

  PlayerScreen({
    Key key,
    @required this.channel,
    this.toNext,
    this.toPrev,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  VideoPlayerController _controller;
  double _aspectRatio = aspectRatio43;
  bool _controlsVisible = false;
  HLSVideoCache _cache;
  Timer _controlsTimer;
  static const Duration _controlsTimeout = Duration(seconds: 3);
  User _user;
  bool _forceFullscreen = false;
  bool _expandProgram = false;
  ExpandableController _expandableController;

  @override
  void initState() {
    super.initState();
    _enableAllOrientations();
    _restoreUser();
    if (!widget.channel.locked) {
      _loadVideo(widget.channel);
    }
    _expandableController = ExpandableController(initialExpanded: _expandProgram);
    _expandableController.addListener(_toggleProgram);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _restoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      String userInfo = prefs.getString('user');
      _user =  User.fromJson(jsonDecode(userInfo));
    }
  }

  @override
  void dispose() {
    _disposeController();
    _clearCache();
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    _enablePortraitOnly();
    _expandableController.removeListener(_toggleProgram);
    _expandableController.dispose();
    super.dispose();
  }

  @override void didChangeMetrics() {
    Wakelock.enable();
  }

  void _enableAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _enablePortraitOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _enableLandscapeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _disposeController() {
    _controller?.dispose();
  }

  void _clearCache() {
    _cache?.clear();
  }

  Future<void> _loadVideo(Channel channel) async {
    _cache = HLSVideoCache(channel.url);
    await _cache.load();
    VideoPlayerController controller = VideoPlayerController.cache(_cache);
    await controller.initialize();
    setState(() {
      _controller = controller;
      _aspectRatio = controller.value.aspectRatio ?? _aspectRatio;
    });
    controller.play();
  }

  void _showSettings() {
    // TODO: show items: change aspect ratio and favorites
    // setState(() {
    //   _aspectRatio = ratio > 0 ? ratio : _controller.value.aspectRatio;
    // });
  }

  void _toPrev() {
    if(widget.toPrev != null) {
      Navigator.of(context).pop();
      widget.toPrev();
    }
  }

  void _toNext() {
    if(widget.toNext != null) {
      Navigator.of(context).pop();
      widget.toNext();
    }
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
    if (_controlsVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  // chromecast be here
  // void _chromecast() {
  //
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

  bool get _fullscreen {
    return _forceFullscreen ||
      MediaQuery.of(context).orientation == Orientation.landscape;
  }

  void _swipeChannel(DragEndDetails details) {
    if(details.primaryVelocity > 0) {
      _toPrev();
    } else {
      _toNext();
    }
  }

  Widget get _player {
    if (_fullscreen) {
      return  GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: Material(
          color: AppColors.black,
          child: Stack(
            children: [
              Center (
                child: _controller == null ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray5),
                  strokeWidth: 10,
                ) : AspectRatio(
                  aspectRatio: _aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                ),
              ),
              _controls,
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _toggleControls,
        onHorizontalDragEnd: _swipeChannel,
        child: AspectRatio(
          aspectRatio: _aspectRatio,
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
  }

  void _goLive() {

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
                          widget.channel.title,
                          style: AppFonts.screenTitle,
                        ) : null,
                      ),
                    ),
                    // chromecast be here
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
                      onPressed: _toPrev,
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
                      onPressed: _toNext,
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

  void _toggleFullScreen() {
    if (_forceFullscreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() {
    _enableLandscapeOnly();
    setState(() {
      _forceFullscreen = true;
    });
  }

  void _exitFullScreen() {
    _enableAllOrientations();
    setState(() {
      _forceFullscreen = false;
    });
  }

  Future<bool> _willPop() async {
    if(_fullscreen) {
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
      title: Text(widget.channel.title, style: AppFonts.screenTitle),
      centerTitle: true,
      actions: [
        IconButton(
          icon: AppIcons.favAdd,
          onPressed: () {NavItems.inDevelopment(context, title: 'Избранное');},
        ),
      ],
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

  void _login() {
    Navigator.of(context).pop(NavItems.login);
  }

  void _toggleProgram() {
    setState(() {
      _expandProgram = !_expandProgram;
    });
  }

  Widget get _expandBtn {
    return AnimatedAlign(
      child: ExpandableButton (
        child: _expandProgram
            ? AppIcons.hideProgram
            : AppIcons.showProgram,
      ),
      alignment: _expandProgram
          ? Alignment.bottomRight
          : Alignment.topRight,
      duration: Duration(milliseconds: 100),
    );
  }

  Widget _program(BuildContext context, AsyncSnapshot<List<Program>> snapshot) {
    final program = snapshot.data;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 15),
      child: program == null ? Text(
        snapshot.connectionState == ConnectionState.waiting
            ? 'Загружаю программу ...'
            : 'Программа для этого канала недоступна',
        style: AppFonts.currentProgramTitle,
        textAlign: TextAlign.center,
      ) : ExpandableNotifier(
        controller: _expandableController,
        child: Stack(
          children: [
            Expandable(
              collapsed: _programTile(program.first, first: true),
              expanded: SingleChildScrollView(
                child: Column(
                  children: program.map((item) => _programTile(
                    item,
                    first: item == program.first,
                  )).toList(),
                ),
              ),
            ),
            _expandBtn,
          ],
        ),
      ),
    );
  }

  Widget _programTile(Program program, {bool first: false}) {
    List<Widget> programText = [
      Text(
        program.title,
        style: first ? AppFonts.currentProgramTitle : AppFonts.programTitle,
      ),
    ];
    if(first) {
      programText.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 5, 0),
              child: AppIcons.pinkDot,
            ),
            Text(
              'Сейчас в эфире',
              style: AppFonts.nowOnAir,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, first ? 0 : 5, 44, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Text(
              program.startTime,
              style: first ? AppFonts.currentProgramTime : AppFonts.programTime,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: programText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _title {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppColors.transparentBlack,
            )
          )
        ),
        child: Text(widget.channel.title, style: AppFonts.videoTitle),
      ),
    );
  }

  Widget get _lockInfo {
    // TODO: finish this
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparentGray,
        borderRadius: BorderRadius.circular(13),
      ),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 27),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _user == null
              ? 'Войдите, чтобы получить доступ к данному каналу'
              : "Для разблокировки канала подключите один из пакетов",
          ),
          TextButton(
            onPressed: _login,
            child: Text("Войти", style: AppFonts.channelLogin),
          )
        ],
      )
    );
  }

  Widget get _body {
    if(_fullscreen) return _player;
    List<Widget> children = [
      _player,
      _title,
      Expanded(
        child: FutureBuilder(
          future: widget.channel.getProgram(),
          builder: _program,
        )
      ),
    ];
    if(widget.channel.locked) {
      children.add(_lockInfo);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBody: false,
        extendBodyBehindAppBar: false,
        appBar: _fullscreen ? null : _appBar,
        body: _body,
        bottomNavigationBar: _fullscreen ? null : _bottomBar,
      ),
    );
  }
}


// TODO: сделать кнопку live.
