import 'package:flutter/material.dart';
import 'package:me_play/widgets/future_block.dart';
import 'package:me_play/widgets/packet_carousel.dart';
import '../utils/settings.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/modals.dart';
import '../widgets/bottom_navbar.dart';
import '../models.dart';
import '../theme.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  List<Packet> _packets;
  User _user;
  
  @override
  void initState() {
    super.initState();
  }

  Future<List<Packet>> _loadData() async {
    await _loadUser();
    if (_user == null) await _login();
    if (_user == null) Navigator.of(context).pop();
    return _loadPackets();
  }

  Future<void> _loadUser() async {
    User user = await User.getUser();
    _user = user;
  }

  Future<void> _login() async {
    User user = await Navigator.of(context).pushNamed<User>('/login');
    _user = user;
  }

  Future<List<Packet>> _loadPackets() async {
    List<Packet> packets = await _user.getPackets();
    _packets = packets;
    return packets;
  }

  // TODO: move to settings
  // Future<void> _logout() async {
  //   await User.clearUser();
  //   await Future.wait([
  //     Channel.loadTv(),
  //     Channel.loadRadio(),
  //   ]);
  //   Channel.loadRecent();
  //   Channel.loadPopular();
  //   Navigator.of(context).pop();
  // }

  // TODO: move to settings
  // void _logoutDialog() {
  //   modals.oldConfirmModal(
  //     context: context,
  //     title: Text('Выход'),
  //     content: Text('Вы уверены, что хотите выйти?'),
  //     action: _logout,
  //   );
  // }

  Future<bool> _connect(Packet packet) async {
    // Костыль, должно быть сделано на бэкенде.
    const exclusivePackets = [5, 6, 7];
    if (exclusivePackets.contains(packet.id)) {
      for (Packet p in _packets) {
        if (p.isActive && exclusivePackets.contains(p.id)) {
          await _disconnect(p);
        }
      }
    }
    List<Packet> packets = await _user.addPacket(packet);
    if (packets == null) return false;
    setState(() {
      _packets = packets;
    });
    return true;
  }

  Future<bool> _disconnect(Packet packet) async {
    List<Packet> packets = await _user.removePacket(packet);
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
      builder: (BuildContext context) => ConfirmDialog(
        action: () async => await _connect(packet),
        title: packet.name,
        text: '${l.packetDisconnect}\n${packet.name}?',
        error: '${l.packetDisconnectError} ${packet.name}. ${l.tryLater}',
      ),
    );
  }

  Widget get _body {
    return FutureBlock<List<Packet>>(
      future: _loadData(),
      builder: (BuildContext context, packets) {
        return PacketCarousel(
          packets: packets,
          connect: _connectDialog,
          disconnect: _disconnectDialog,
        );
      },
    );


      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.stretch,
      //   children: [
      //     Container(
      //       decoration: BoxDecoration(
      //         color: AppColors.gray0,
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15,),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           AppIcons.profile,
      //           Text(_user == null ? 'Профиль' : '+' + _user.username, style: AppFonts.profileName,),
      //           Padding(
      //             padding: EdgeInsets.symmetric(vertical: 5),
      //             child: Text('ПОДКЛЮЧЕННЫЕ\nПАКЕТЫ', style: AppFonts.activePacketsTitle, textAlign: TextAlign.center,),
      //           ),
      //           Text(_activePacketNames, style: AppFonts.activePacketList),
      //           Padding(
      //             padding: EdgeInsets.only(top: 15),
      //             child: Row(
      //               children: [
      //                 TextButton(
      //                   onPressed: _changePassword,
      //                   child: Text('Сменить пароль', style: AppFonts.profileAction,),
      //                 ),
      //                 Expanded(child: Container()),
      //                 TextButton(
      //                   onPressed: _logoutDialog,
      //                   child: Text('Выход', style: AppFonts.profileAction,),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 30),
      //       child: Text('Пакеты', style: AppFonts.packetListTitle,)
      //     ),
      //     Expanded(
      //       child: Padding(
      //         padding: EdgeInsets.only(top: 10),
      //         child: SingleChildScrollView(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.stretch,
      //             children: _packetTiles,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    // );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/profile/settings');
  }

  Widget get _appBar {
    // TODO: refactor whole AppToolBar to show subtitle properly.
    AppLocalizations l = locale(context);
    return AppToolBar(
      title: _user == null ? l.profileTitle : '+${_user.username}',
      subtitle: l.profileTitle,
      actions: [
        IconButton(
          icon: AppIconsV2.cog,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget get _bottomNavBar => BottomNavBar(
    showIndex: NavItems.profile,
  );

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
