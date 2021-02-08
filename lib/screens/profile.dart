import 'package:flutter/material.dart';
import 'base.dart';
import '../models.dart';
import '../theme.dart';


class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({Key key, this.user}): super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  String get _activePacketNames {
    // TODO
    return 'Пакет, Пакет';
  }

  void _changePassword() {
    NavItems.inDevelopment(context, title: 'Смена пароля');
  }

  void _logout() {
    // TODO: выход из base.
  }

  void _addPacket(Packet packet) {
    // TODO
  }

  void _removePacket(Packet packet) {
    // TODO
  }

  List<Widget> get _packetTiles {
    // TODO
    return [
      GestureDetector(
        onTap: () { _addPacket(null); },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.gray0,
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15,),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(text: TextSpan(children: [
                        TextSpan(text: 'ЛАЙТ', style: AppFonts.packetName),
                        TextSpan(text: ' (50 КАНАЛОВ)', style: AppFonts.channelCount),
                      ])),
                      Text('0 сом / сутки', style: AppFonts.packetPrice,),
                    ],
                  )
                )
              ),
              AppIcons.plus,
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                  child: Text('ПОДКЛЮЧЕННЫЕ\nПАКЕТЫ', style: AppFonts.activePacketsTitle,),
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
