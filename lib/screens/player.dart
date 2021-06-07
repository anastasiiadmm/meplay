import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:me_play/utils/settings.dart';
import 'package:screen/screen.dart';
import 'package:wakelock/wakelock.dart';
import 'package:expandable/expandable.dart';
import 'package:device_info/device_info.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/player.dart';
import '../widgets/program_list.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/orientation_helper.dart';
import '../utils/local_notification_helper.dart';


class PlayerScreen extends StatefulWidget {
  final int channelId;
  final ChannelType channelType;
  final List<Channel> channels;

  PlayerScreen({
    Key key,
    @required this.channelId,
    this.channelType: ChannelType.tv,
    this.channels,
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
    await Future.wait([
      _loadUser(),
      _loadChannel(),
    ]).then((_) {
      _loadFavorite();
      _addRecent();
    });
  }

  void _addRecent() {
    if(_channel.type == ChannelType.tv) Channel.addRecent(_channel);
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
      toPrevChannel: _toPrev,
      toNextChannel: _toNext,
      pipMode: _pipMode,
    );
  }

  void _toPrev() {
    setState(() {
      _channel = _channel.next(widget.channels);
      _playerKey = GlobalKey();
    });
    _loadFavorite();
  }

  void _toNext() {
    setState(() {
      _channel = _channel.prev(widget.channels);
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
    return AppToolBar(
      title: _channel?.title ?? '',
      actions: [
        if(_user != null) _favButton,
      ],
    );
  }

  Widget get _bottomBar => BottomNavBar();

  void _toggleProgram() {
    setState(() {
      _expandProgram = !_expandProgram;
    });
  }

  Future<bool> _scheduleNotification(Program program) async {
    await LocalNotificationHelper.instance.schedule(
      '${program.title}',
      // TODO: translate
      'На канале ${_channel.name} в ${program.startTime}!',
      program.start.subtract(Duration(minutes: 5)),
      data: {
        'program': program.title,
        'channelId': _channel.id,
        'channelName': _channel.name,
        'startTime': program.startDateTime,
        'link': (_channel.type == ChannelType.tv ? '/tv/' : '/radio/')
            + _channel.id.toString(),
      },
    );
    return true;
  }

  void _scheduleNotificationDialog(Program program) {
    AppLocalizations l = locale(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        title: l.remindModalTitle,
        text: '${l.remindModalText} "${program.title}" ${program.startDateTime}?',
        action: () => _scheduleNotification(program),
      ),
    );
  }

  Widget _textBlock(String text) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        text,
        style: AppFontsV2.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _program {
    return FutureBuilder<List<Program>>(
      future: _channel.program(),
      builder: (BuildContext context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return _textBlock("Программа загружается...");
        } else if(snapshot.hasData) {
          return ProgramList(
            program: snapshot.data,
            action: _channel.locked
                ? null
                : _scheduleNotificationDialog,
          );
        } else {
          return _textBlock('Программа недоступна');
        }
      },
    );
  }

  Widget get _body {
    if(_fullscreen || _pipMode) return _player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _player,
        if(_channel != null) Expanded(
          child: _program,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pipMode) return _player;
    return Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      appBar: _fullscreen ? null : _appBar,
      body: _body,
      bottomNavigationBar: _fullscreen ? null : _bottomBar,
    );
  }
}
