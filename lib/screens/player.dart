import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:wakelock/wakelock.dart';

import '../channel.dart';
import '../models.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/local_notification_helper.dart';
import '../utils/orientation_helper.dart';
import '../utils/pref_helper.dart';
import '../utils/settings.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../widgets/player.dart';
import '../widgets/program_list.dart';

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

class _PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver {
  User _user;
  Channel _channel;
  Key _playerKey = GlobalKey();
  double _initialBrightness;
  int _androidSdkLevel = 0;
  bool _pipMode = false;
  bool _favorite = false;
  double _volume;
  VideoBufferSize _bufferSize;
  bool _isTv;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _initAsync();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initAsync() async {
    print(widget.channelId);
    _isTv = await isTv();
    if (!_isTv) OrientationHelper.allowAll();
    await Future.wait([
      _initBrightness(),
      _initPlatformState(),
      _loadVolume(),
      _loadBufferSize(),
    ]);
    await Future.wait([
      _loadUser(),
      _loadChannel(),
    ]);
    _loadFavorite();
    _addRecent();
    _enablePip();
  }

  void _addRecent() {
    if (_channel.type == ChannelType.tv) Channel.addRecent(_channel);
  }

  Future<void> _loadChannel() async {
    Channel channel = await Channel.getChannel(
      widget.channelId,
      widget.channelType,
    );
    setState(() {
      _channel = channel;
    });
    if (channel.locked) _showLockedDialog();
  }

  void _showLockedDialog() {
    AppLocalizations l = locale(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        title: l.channelLockedTitle,
        text: l.channelLockedText,
        ok: l.confirm,
        cancel: l.cancel,
        autoPop: false,
        action: () async {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.profile,
            (route) {
              return route.isFirst;
            },
          );
          return true;
        },
      ),
    );
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
    if (user != null)
      setState(() {
        _user = user;
      });
  }

  Future<void> _loadFavorite() async {
    if (_user != null && _channel != null) {
      bool favorite = await _user.hasFavorite(_channel);
      setState(() {
        _favorite = favorite;
      });
    }
  }

  Future<void> _loadVolume() async {
    _volume = await PrefHelper.loadString(
      PrefKeys.volume,
      restore: (value) => double.tryParse(value),
    );
  }

  Future<void> _loadBufferSize() async {
    _bufferSize = await PrefHelper.loadString(
      PrefKeys.bufferSize,
      restore: (value) => VideoBufferSize.getByName(value),
    );
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
    if (!_isTv) OrientationHelper.forcePortrait();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    Wakelock.enable();
  }

  void _enablePip() {
    if (_channel?.locked == false && !Platform.isIOS) {
      enablePip();
    }
  }

  void _disablePip() {
    if (!Platform.isIOS) {
      disablePip();
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _enterPipMode();
    } else if (state == AppLifecycleState.resumed) {
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
      initialVolume: _volume,
      onVolumeChange: _setVolume,
      bufferSize: _bufferSize,
    );
  }

  void _setVolume(double volume) {
    _volume = volume;
    PrefHelper.saveString(PrefKeys.volume, '$volume');
  }

  void _toPrev() {
    Channel channel = _channel.prev(widget.channels);
    if (channel == _channel) return;
    setState(() {
      _channel = channel;
      _playerKey = GlobalKey();
    });
    _loadFavorite();
    if (channel.locked) _showLockedDialog();
  }

  void _toNext() {
    Channel channel = _channel.next(widget.channels);
    if (channel == _channel) return;
    setState(() {
      _channel = channel;
      _playerKey = GlobalKey();
    });
    _loadFavorite();
    if (channel.locked) _showLockedDialog();
  }

  void _enterPipMode() {
    if (_androidSdkLevel != null && _androidSdkLevel > 25) {
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
    if (user != null) {
      await user.addFavorite(_channel);
      setState(() {
        _favorite = true;
      });
    }
  }

  Future<void> _removeFavorite() async {
    User user = await User.getUser();
    if (user != null) {
      await user.removeFavorite(_channel);
      setState(() {
        _favorite = false;
      });
    }
  }

  Widget get _favButton => IconButton(
        icon: _favorite ? AppIcons.starActive : AppIcons.star,
        padding: EdgeInsets.all(8),
        iconSize: 28,
        constraints: BoxConstraints(),
        onPressed: _favorite ? _removeFavorite : _addFavorite,
      );

  Widget get _appBar {
    return AppToolBar(
      title: _channel?.title ?? '',
      actions: [
        if (_user != null) _favButton,
      ],
    );
  }

  Widget get _bottomBar => BottomNavBar();

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
        'link': (_channel.type == ChannelType.tv ? '/tv/' : '/radio/') +
            _channel.id.toString(),
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
        text:
            '${l.remindModalText} "${program.title}" ${program.startDateTime}?',
        action: () => _scheduleNotification(program),
      ),
    );
  }

  Widget _textBlock(String text) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        text,
        style: AppFonts.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _program {
    return FutureBuilder<List<Program>>(
      future: _channel.program(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _textBlock("Программа загружается...");
        } else if (snapshot.hasData) {
          return ProgramList(
            program: snapshot.data,
            action: _channel.locked ? null : _scheduleNotificationDialog,
          );
        } else {
          return _textBlock('Программа недоступна');
        }
      },
    );
  }

  Widget get _body {
    if (_fullscreen || _pipMode) return _player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _player,
        if (_channel != null)
          Expanded(
            child: _program,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pipMode) return _player;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _fullscreen ? null : _appBar,
      body: _body,
      bottomNavigationBar: _fullscreen ? null : _bottomBar,
    );
  }
}
