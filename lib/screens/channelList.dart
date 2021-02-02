import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class ChannelListScreen extends StatefulWidget {
  final List<Channel> channels;

  ChannelListScreen({Key key, this.channels}): super();

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}


class _ChannelListScreenState extends State<ChannelListScreen> {
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

  Widget get _body {

  }

  Widget get _appBar {

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      extendBody: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
