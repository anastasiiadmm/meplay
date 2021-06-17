import 'package:flutter/material.dart';
import 'package:me_play/widgets/packet_carousel.dart';
import 'package:me_play/widgets/rotation_loader.dart';
import '../utils/settings.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  User _user;
  List<Packet> _packets;
  List<Channel> _channels;
  int _activePacketId = 0;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadUser();
    if (_user == null) await _login();
    if (_user == null) Navigator.of(context).pop();
    _loadPackets();
    _loadChannels();
  }

  Future<void> _loadUser() async {
    User user = await User.getUser();
    setState(() { _user = user; });
  }

  Future<void> _login() async {
    User user = await Navigator.of(context).pushNamed<User>('/login');
    setState(() { _user = user; });
  }

  Future<void> _loadPackets() async {
    List<Packet> packets = await _user.getPackets();
    setState(() { _packets = packets; });
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.tvChannels();
    setState(() { _channels = channels; });
  }

  Future<bool> _connect(Packet packet) async {
    // Костыль, должно быть сделано на бэкенде.
    const exclusivePackets = [5, 6, 7];
    if (exclusivePackets.contains(packet.id)) {
      for (Packet p in _packets) {
        if (p.isActive && exclusivePackets.contains(p.id)) {
          await _disconnect(p, reload: false);
        }
      }
    }
    List<Packet> packets = await _user.addPacket(packet);
    await Channel.fullReload();
    if (packets == null) return false;
    setState(() {
      _packets = packets;
    });
    return true;
  }

  Future<bool> _disconnect(Packet packet, {reload: true}) async {
    List<Packet> packets = await _user.removePacket(packet);
    if(reload) await Channel.fullReload();
    if (packets == null) return false;
    setState(() {
      _packets = packets;
    });
    return true;
  }
  
  void _connectDialog(Packet packet) {
    AppLocalizations l = locale(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmDialog(
        action: () async => await _connect(packet),
        title: packet.name,
        text: '${l.packetConnect}\n${packet.name}?',
        error: '${l.packetConnectError} ${packet.name}. ${l.tryLater}',
      ),
    );
  }
  
  void _disconnectDialog(Packet packet) {
    AppLocalizations l = locale(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmDialog(
        action: () async => await _disconnect(packet),
        title: packet.name,
        text: '${l.packetDisconnect}\n${packet.name}?',
        error: '${l.packetDisconnectError} ${packet.name}. ${l.tryLater}',
      ),
    );
  }

  void _carouselChange(int id) {
    setState(() { _activePacketId = id; });
  }

  int get _maxChannels {
    Packet packet = _packets[_activePacketId];
    switch(packet.id) {
      case 5: return 50;
      case 6: return 80;
      case 7: return _channels.length;
      default: return 0;
    }
  }

  List<String> get _channelTitles {
    Packet packet = _packets[_activePacketId];
    switch(packet.id) {
      case 8: return [
        '2. Баластан (ОТРК)',
        '32. Карусель',
        '64. Gulli-girl',
        '72. Nickelodeon',
        '73. Nick Jr.',
        '88. Мульт',
        '98. NickToons',
        '103. Tiji (Россия)',
        '114. Малыш',
        '129. В гостях у сказки...',
        '130. Dorama',
        '137. Мама',
      ];
      case 21: return [
        '6. Спорт (КТРК)',
        '8. QSport',
        '9. QSport Арена',
        '45. Авто 24',
        '97. КХЛ ТВ',
        '101. Евроспорт 1',
        '102. Евроспорт 2',
        '110. Мир увлечений',
        '112. M1-Global TV',
        '113. Бокс ТВ',
        '153. Fightbox',
        '154. Авто Плюс',
      ];
      default: return null;
    }
  }
  
  Widget get _channelList {
    AppLocalizations l = locale(context);

    List<Widget> children = [
      Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          l.profileChannelList,
          style: AppFonts.blockTitle,
        ),
      ),
    ];
    
    int maxChannels = _maxChannels;
    if(maxChannels > 0) {
      for(int i = 0; i < maxChannels; i++) {
        children.add(Text(
          _channels[i].title,
          style: AppFonts.midText,
        ));
      }
    } else {
      List<String> titles = _channelTitles;
      if(titles == null) children.add(Text(
        l.packetChannelsEmpty,
        style: AppFonts.textSecondary,
        textAlign: TextAlign.center,
      ));
      else {
        for(int i = 0; i < _channelTitles.length; i++) {
          children.add(Text(
            _channelTitles[i],
            style: AppFonts.midText,
          ));
        }
      }
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget get _body {
    return _packets == null ? Center(
      child: RotationLoader(),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PacketCarousel(
          packets: _packets,
          connect: _connectDialog,
          disconnect: _disconnectDialog,
          activeId: _activePacketId,
          onChange: _carouselChange,
        ),
        Expanded(
          child: _channelList,
        ),
      ],
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  Widget get _appBar {
    // TODO: refactor AppToolBar to show subtitle properly.
    AppLocalizations l = locale(context);
    return AppToolBar(
      title: _user == null ? l.profileTitle : '+${_user.username}',
      subtitle: l.profileTitle,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: AppIconButton(
            icon: AppIcons.cog,
            onPressed: _openSettings,
            padding: EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget get _bottomNavBar => BottomNavBar(
    showIndex: NavItems.profile,
  );

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
