import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:expandable/expandable.dart';

import 'base.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../widgets/player.dart';


class PlayerScreen extends StatefulWidget {
  final Channel channel;
  final Channel Function(Channel) getNextChannel;
  final Channel Function(Channel) getPrevChannel;

  PlayerScreen({
    Key key,
    @required this.channel,
    this.getNextChannel,
    this.getPrevChannel,
  }) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  User _user;
  bool _expandProgram = false;
  Channel _channel;
  ExpandableController _expandableController;
  Key _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    OrientationHelper.allowAll();
    _restoreUser();
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
    Wakelock.disable();
    WidgetsBinding.instance.removeObserver(this);
    OrientationHelper.forcePortrait();
    _expandableController.removeListener(_toggleProgram);
    _expandableController.dispose();
    super.dispose();
  }

  @override void didChangeMetrics() {
    Wakelock.enable();
  }

  bool get _fullscreen {
    return OrientationHelper.isFullscreen(context);
  }

  Widget get _player {
    return HLSPlayer(
      key: _playerKey,
      channel: _channel,
      toPrevChannel: _toPrevChannel,
      toNextChannel: _toNextChannel,
    );
  }

  void _toPrevChannel() {
    setState(() {
      _channel = widget.getPrevChannel(_channel);
      _playerKey = GlobalKey();
    });
  }

  void _toNextChannel() {
    setState(() {
      _channel = widget.getNextChannel(_channel);
      _playerKey = GlobalKey();
    });
  }

  Future<bool> _willPop() async {
    if(_fullscreen) {
      OrientationHelper.allowAll();
      return false;
    }
    return true;
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _onNavTap(int index) {
    Navigator.of(context).pop(index);
  }

  void _login() {
    Navigator.of(context).pop(NavItems.login);
  }

  void _profile() {
    Navigator.of(context).pop(NavItems.profile);
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
      title: Text(_channel.title, style: AppFonts.screenTitle),
      centerTitle: true,
      actions: [
        IconButton(
          icon: AppIcons.favAdd,
          onPressed: () {NavItems.inDevelopment(context, title: 'Избранное');},
        ),
      ],
    );
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
      padding: EdgeInsets.only(top: 20),
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
              expanded: Column(
                children: program.map((item) => _programTile(
                  item,
                  first: item == program.first,
                )).toList(),
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
      padding: EdgeInsets.fromLTRB(0, first ? 0 : 5, 50, 0),
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

  Widget get _lockInfo {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lockBg,
        borderRadius: BorderRadius.circular(13),
      ),
      margin: EdgeInsets.fromLTRB(12, 15, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcons.lockChannelLarge,
          Text(
            _user == null
                ? 'Канал недоступен.\nДля разблокировки канала\nНеобходимо войти.'
                : "Канал недоступен.\nДля разблокировки канала\nПодключите один из пакетов.",
            style: AppFonts.lockText,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _user == null ? _login : _profile,
            child: Text(
              _user == null ? "ВОЙТИ" : "НАСТРОЙКИ",
              style: AppFonts.lockLogin,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _body {
    if(_fullscreen) return _player;
    List<Widget> children = [
      FutureBuilder(
        future: _channel.program,
        builder: _program,
      ),
    ];
    if(_channel.locked) {
      children.add(_lockInfo);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _player,
        Expanded (
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _fullscreen ? null : _appBar,
        body: _body,
        bottomNavigationBar: _fullscreen ? null : _bottomBar,
      ),
    );
  }
}


// TODO: сделать кнопку live.
// TODO: вывести инфо о днях в программе.
