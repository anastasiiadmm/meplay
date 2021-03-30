import 'package:flutter/material.dart';
import 'login.dart';
import '../widgets/modals.dart' as modals;
import '../widgets/bottomNavBar.dart';
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
    _initAsync();
  }

  Future<void> _initAsync() async {
    User user = await User.getUser();
    if (user == null) user = await _login();
    if (user == null) Navigator.of(context).pop();
    else {
      List<Packet> packets = await user.getPackets();
      setState(() {
        _user = user;
        _packets = packets;
      });
    }
  }

  Future<User> _login() async {
    return Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    await User.clearUser();
    await Channel.loadChannels();
    Navigator.of(context).pop();
  }

  void _logoutDialog() {
    modals.confirmModal(
      context: context,
      title: Text('Выход'),
      content: Text('Вы уверены, что хотите выйти?'),
      action: _logout,
    );
  }

  String get _activePacketNames {
    if (_packets == null) {
      return 'Информация о пакетах недоступна';
    }
    final activePackets = _packets.where((packet) => packet.isActive);
    if (activePackets.length == 0) {
      return "Нет активных пакетов";
    }
    return activePackets.map((packet) => packet.name).join(', ');
  }

  void _changePassword() {
    modals.inDevelopment(context, title: 'Смена пароля');
  }

  Future<bool> _addPacket(Packet packet) async {
    // Костыль, должно быть сделано на бэкенде.
    const exclusivePackets = [5, 6, 7];
    if (exclusivePackets.contains(packet.id)) {
      for (Packet p in _packets) {
        if (p.isActive && exclusivePackets.contains(p.id)) {
          await _removePacket(p);
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

  Future<bool> _removePacket(Packet packet) async {
    List<Packet> packets = await _user.removePacket(packet);
    if (packets == null) return false;
    setState(() {
      _packets = packets;
    });
    return true;
  }
  
  void _addPacketDialog(Packet packet) {
    final title = Text('Подключить пакет', textAlign: TextAlign.center,);
    final text = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppFonts.packetPrice,
        children: [
          TextSpan(text: 'Вы уверены, что хотите подключить пакет ',),
          TextSpan(text: packet.name.toUpperCase(), style: AppFonts.packetName),
          TextSpan(text: ' за\n',),
          TextSpan(text: packet.priceLabel, style: AppFonts.packetName,),
          TextSpan(text: '?',),
        ],
      ),
    );
    final error = Text(
      'Не удалось подключить пакет. Проверьте подключение к интернету и баланс, и попробуйте ещё раз.',
       textAlign: TextAlign.center
    );
    modals.asyncConfirmModal(
      context: context,
      title: title,
      content: text,
      error: error,
      action: () => _addPacket(packet),
    );
  }
  
  void _removePacketDialog(Packet packet) {
    final title = Text('Отключить пакет', textAlign: TextAlign.center,);
    final text = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppFonts.packetPrice,
        children: [
          TextSpan(text: 'Вы уверены, что хотите отключить пакет ',),
          TextSpan(text: packet.name.toUpperCase(), style: AppFonts.packetName),
          TextSpan(text: ' за\n',),
          TextSpan(text: packet.priceLabel, style: AppFonts.packetName),
          TextSpan(text: '?',),
        ],
      ),
    );
    final error = Text(
      'Не удалось отключить пакет. Проверьте подключение к интернету, и попробуйте ещё раз.',
      textAlign: TextAlign.center,
    );
    modals.asyncConfirmModal(
      context: context,
      title: title,
      content: text,
      error: error,
      action: () => _removePacket(packet),
    );
  }
  
  Widget _buildPacketTile(Packet packet) {
    return GestureDetector (
      onTap: packet.isActive
          ? () { _removePacketDialog(packet); }
          : () { _addPacketDialog(packet); },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: packet.isActive
              ? AppColors.gray0
              : AppColors.transparentLight,
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15,),
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(children: [
                      TextSpan(
                          text: packet.name.toUpperCase(),
                          style: AppFonts.packetName
                      ),
                      TextSpan(
                          text: " (${packet.channelDisplay})",
                          style: AppFonts.channelCount
                      ),
                    ])),
                    Text(
                      packet.priceLabel,
                      style: AppFonts.packetPrice,
                    ),
                  ],
                ),
              ),
            ),
            packet.isActive ? AppIcons.check : AppIcons.plus,
          ],
        ),
      ),
    );
  }

  List<Widget> get _packetTiles {
    if (_packets == null) {
      return [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.gray0,
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Animations.modalProgressIndicator,
          ),
        ),
      ];
    }
    return _packets.map((item) {
      final Packet packet = item;
      return _buildPacketTile(packet);
    }).toList();
  }

  Widget get _body {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.gray0,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcons.profile,
                Text(_user == null ? 'Профиль' : '+' + _user.username, style: AppFonts.profileName,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('ПОДКЛЮЧЕННЫЕ\nПАКЕТЫ', style: AppFonts.activePacketsTitle, textAlign: TextAlign.center,),
                ),
                Text(_activePacketNames, style: AppFonts.activePacketList),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _changePassword,
                        child: Text('Сменить пароль', style: AppFonts.profileAction,),
                      ),
                      Expanded(child: Container()),
                      TextButton(
                        onPressed: _logoutDialog,
                        child: Text('Выход', style: AppFonts.profileAction,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text('Пакеты', style: AppFonts.packetListTitle,)
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _packetTiles,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _back() {
    Navigator.of(context).pop();
  }

  void _openSettings() {

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
      actions: [
        IconButton(
          onPressed: _openSettings,
          icon: AppIcons.cog,
        )
      ],
      title: _appBarTitle,
      centerTitle: true,
    );
  }

  Widget get _appBarTitle => _user == null ? Text(
    'Личный кабинет',
    style: AppFonts.screenTitle,
    textAlign: TextAlign.center,
  ) : Column(
    children: [
      Text(_user.username, style: AppFonts.screenTitle),
      Text('Личный кабинет', style: AppFonts.screenSubTitle),
    ],
  );

  Widget get _bottomNavBar => BottomNavBar(showIndex: NavItems.profile);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
