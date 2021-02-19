import 'package:flutter/material.dart';
import 'base.dart';
import '../models.dart';
import '../theme.dart';


class ProfileScreen extends StatefulWidget {
  final User user;
  final void Function() logout;

  ProfileScreen({Key key, this.user, this.logout}): super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  List<Packet> _packets;
  
  @override
  void initState() {
    super.initState();
    _loadPackets();
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
    NavItems.inDevelopment(context, title: 'Смена пароля');
  }

  void _logout() {
    widget.logout();
  }

  Future<bool> _addPacket(Packet packet) async {
    List<Packet> packets = await widget.user.addPacket(packet);
    if (packets == null) return false;
    setState(() {
      _packets = packets;
    });
    return true;
  }

  Future<bool> _removePacket(Packet packet) async {
    List<Packet> packets = await widget.user.removePacket(packet);
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
    _showPacketDialog(title, text, error, () => _addPacket(packet));
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
    _showPacketDialog(title, text, error, () => _removePacket(packet));
  }

  Future<void> _showPacketDialog(
    Widget title,
    Widget text,
    Widget error,
    Future<bool> Function() action,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool _loading = false;
        bool _failed = false;
        return StatefulBuilder(
          builder: (BuildContext context, setState) => AlertDialog(
            title: title,
            content: _loading ? Container(
              child: Animations.modalProgressIndicator,
              alignment: Alignment.center,
              height: 40,
              margin: EdgeInsets.only(top: 20,),
            ) : (_failed ? error : text),
            actions: _failed ? [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Закрыть'),
              ),
            ] : [
              TextButton(
                onPressed: _loading ? null : () async {
                  setState(() {
                    _loading = true;
                  });
                  bool success = await action();
                  if (success) Navigator.of(context).pop();
                  setState(() {
                    _loading = false;
                    _failed = true;
                  });
                },
                child: Text('Да'),
              ),
              TextButton(
                onPressed: _loading ? null : () {
                  Navigator.of(context).pop();
                },
                child: Text('Нет'),
              ),
            ],
          ),
        );
      }
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
  
  Future<void> _loadPackets() async {
    List<Packet> packets = await widget.user.getPackets();
    setState(() {
      _packets = packets;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Text('+' + widget.user.username, style: AppFonts.profileName,),
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
                        onPressed: _logout,
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
}
