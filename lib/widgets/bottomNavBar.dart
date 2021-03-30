import 'package:flutter/material.dart';
import '../theme.dart';


class NavItems {
  static const home = 0;
  static const favorites = 1;
  static const profile =  2;

  static const routes = <int, String>{
    home: '/',
    favorites: 'tv/favorites/',
    profile: 'profile/',
  };

  static bool hasIndex(int index) {
    return !(index == null || index < 0 || index > 2);
  }
}


class BottomNavBar extends StatelessWidget {
  final int index;

  BottomNavBar({Key key, this.index}): super(key: key);

  void _onNavTap(BuildContext context, int newIndex) {
    if (newIndex != index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushNamed(context, NavItems.routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int index) => _onNavTap(context, index),
      currentIndex: NavItems.hasIndex(index) ? index : 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          activeIcon: NavItems.hasIndex(index)
              ? AppIcons.homeActive
              : AppIcons.home,
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
