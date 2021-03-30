import 'package:flutter/material.dart';
import '../theme.dart';


class NavItems {
  static const home = 0;
  static const favorites = 1;
  static const profile =  2;

  static const routes = <String>['/', '/favorites', '/profile'];

  static bool hasIndex(int index) {
    return !(index == null || index < 0 || index > routes.length);
  }
}


class BottomNavBar extends StatelessWidget {
  final int showIndex;

  BottomNavBar({Key key, this.showIndex}): super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index != showIndex) {
      NavigatorState navState = Navigator.of(context);
      navState.popUntil((route) => route.isFirst);
      if(index != NavItems.home) {
        String route = NavItems.routes[index];
        navState.pushNamed(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int index) => _onNavTap(context, index),
      currentIndex: NavItems.hasIndex(showIndex) ? showIndex : 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          activeIcon: NavItems.hasIndex(showIndex)
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
