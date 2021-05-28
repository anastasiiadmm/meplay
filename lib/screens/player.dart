import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:wakelock/wakelock.dart';
import 'package:expandable/expandable.dart';
import 'package:device_info/device_info.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../utils/local_notification_helper.dart';
import '../widgets/player.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';


class PlayerScreen extends StatefulWidget {
  final int channelId;
  final ChannelType channelType;
  final Channel Function(Channel) getNextChannel;
  final Channel Function(Channel) getPrevChannel;

  PlayerScreen({
    Key key,
    @required this.channelId,
    this.channelType: ChannelType.tv,
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
  double _initialBrightness;
  int _androidSdkLevel = 0;
  bool _pipMode = false;
  bool _favorite = false;
  static const platform = const MethodChannel('PIP_CHANNEL');

  @override
  void initState() {
    super.initState();
    OrientationHelper.allowAll();
    Wakelock.enable();
    _initAsync();
    _expandableController = ExpandableController(initialExpanded: _expandProgram);
    _expandableController.addListener(_toggleProgram);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initAsync() async {
    print(widget.channelId);
    _initBrightness();
    _initPlatformState();
    _enablePip();
    Future.wait([
      _loadUser(),
      _loadChannel(),
    ]).then((_) => _loadFavorite());
  }

  Future<void> _loadChannel() async {
    Channel channel = await Channel.getChannel(
      widget.channelId,
      widget.channelType,
    );
    setState(() { _channel = channel; });
  }

  Future<void> _initPlatformState() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _androidSdkLevel = androidInfo.version.sdkInt;
      }
    } on PlatformException {
      _androidSdkLevel = null;
    }
  }

  Future<void> _loadUser() async {
    User user = await User.getUser();
    if (user != null) setState(() { _user = user; });
  }

  Future<void> _loadFavorite() async {
    if (_user != null && _channel != null) {
      bool favorite = await _user.hasFavorite(_channel);
      setState(() { _favorite = favorite; });
    }
  }

  Future<void> _initBrightness() async {
    _initialBrightness = await Screen.brightness;
  }

  void _restoreBrightness() {
    if (_initialBrightness != null) {
      Screen.setBrightness(_initialBrightness);
    }
  }

  @override
  void dispose() {
    Wakelock.disable();
    _restoreBrightness();
    _disablePip();
    OrientationHelper.forcePortrait();
    WidgetsBinding.instance.removeObserver(this);
    _expandableController.removeListener(_toggleProgram);
    _expandableController.dispose();
    super.dispose();
  }

  @override void didChangeMetrics() {
    Wakelock.enable();
  }

  void _enablePip() {
    platform.invokeMethod('enablePip');
  }

  void _disablePip() {
    platform.invokeMethod('disablePip');
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _enterPipMode();
    }
    else if (state == AppLifecycleState.resumed) {
      _exitPipMode();
    }
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
      pipMode: _pipMode,
    );
  }

  void _toPrevChannel() {
    setState(() {
      _channel = widget.getPrevChannel(_channel);
      _playerKey = GlobalKey();
    });
    _loadFavorite();
  }

  void _toNextChannel() {
    setState(() {
      _channel = widget.getNextChannel(_channel);
      _playerKey = GlobalKey();
    });
    _loadFavorite();
  }

  void _enterPipMode() {
    if(_androidSdkLevel != null && _androidSdkLevel > 25) {
      setState(() {
        _pipMode = true;
      });
    }
  }

  void _exitPipMode() {
    setState(() {
      _pipMode = false;
    });
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _login() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushNamed('/login');
  }

  void _profile() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushNamed('/profile');
  }

  Future<void> _addFavorite() async {
    User user = await User.getUser();
    if(user != null) {
      await user.addFavorite(_channel);
      setState(() { _favorite = true; });
    }
  }

  Future<void> _removeFavorite() async {
    User user = await User.getUser();
    if(user != null) {
      await user.removeFavorite(_channel);
      setState(() { _favorite = false; });
    }
  }

  Widget get _favButton {
    if (_user == null) return IconButton(
      icon: AppIcons.favAdd,
      onPressed: _login,
    );
    if (_favorite) return IconButton(
      icon: AppIcons.favRemove,
      onPressed: _removeFavorite,
    );
    return IconButton(
      icon: AppIcons.favAdd,
      onPressed: _addFavorite,
    );
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
      title: Text(_channel?.title ?? '', style: AppFonts.screenTitle),
      centerTitle: true,
      actions: [
        _favButton,
      ],
    );
  }

  Widget get _bottomBar => BottomNavBar();

  void _toggleProgram() {
    setState(() {
      _expandProgram = !_expandProgram;
    });
  }

  void _scheduleProgramNotification(Program program) {
    confirmModal(
      context: context,
      title: Text('Напомнить вам о передаче "${program.title}"?',),
      action: () {
        LocalNotificationHelper.instance.schedule(
          'Передача "${program.title}" начнётся в ${program.startTime}!',
          'На канале "${_channel.title}"',
          program.start.subtract(Duration(minutes: 5)),
          data: {
            'programId': program.id,
            'channelId': _channel.id,
            'link': (_channel.type == ChannelType.tv ? '/tv/' : '/radio/')
                + _channel.id.toString(),
          },
        );
      }
    );
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
    return GestureDetector(
      onLongPress: () => _scheduleProgramNotification(program),
      child: Padding(
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
    if(_fullscreen || _pipMode) return _player;
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
                children: [
                  if(widget.channelType == ChannelType.tv) FutureBuilder(
                    future: _channel?.program ?? null,
                    builder: _program,
                  ),
                  if(_channel?.locked ?? false) _lockInfo,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pipMode) return _player;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _fullscreen ? null : _appBar,
      body: _body,
      bottomNavigationBar: _fullscreen ? null : _bottomBar,
    );
  }
}
