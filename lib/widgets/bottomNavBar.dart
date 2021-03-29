import 'package:flutter/material.dart';
import '../theme.dart';


const Map<int, String> routesMapping = {
  0: '/',
  1: 'tv/favorites/',
  2: 'profile/',
};


class BottomNavBar extends StatelessWidget {
  final int index;

  BottomNavBar({Key key, this.index}): super(key: key);

  void _onNavTap(BuildContext context, int newIndex) {
    if (newIndex != index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushNamed(context, routesMapping[index]);
    }
  }

  bool get _noIndex => index == null || index < 0 || index > 2;

  int get _index => _noIndex ? 0 : index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int index) => _onNavTap(context, index),
      currentIndex: _index,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          activeIcon: _noIndex ? AppIcons.home : AppIcons.homeActive,
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.star,
          activeIcon: AppIcons.starActive,
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user,
          activeIcon: AppIcons.userActive,
          label: 'Профиль',
        ),
      ],
    );
  }
}
