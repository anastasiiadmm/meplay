import 'package:flutter/material.dart';
import 'package:me_play/utils/settings.dart';
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
      backgroundColor: AppColorsV2.navBg,
      onTap: (int index) => _onNavTap(context, index),
      currentIndex: NavItems.hasIndex(showIndex) ? showIndex : 0,
      selectedLabelStyle: AppFontsV2.tabbar,
      unselectedLabelStyle: AppFontsV2.tabbar,
      selectedItemColor: AppColorsV2.textSecondary,
      unselectedItemColor: AppColorsV2.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: AppIconsV2.home,
          activeIcon: NavItems.hasIndex(showIndex)
              ? AppIconsV2.homeActive
              : AppIconsV2.home,
          label: locale(context).tabbarMain,
        ),
        BottomNavigationBarItem(
          icon: AppIconsV2.heart,
          activeIcon: AppIconsV2.heartActive,
          label: locale(context).tabbarFavorites,
        ),
        BottomNavigationBarItem(
          icon: AppIconsV2.user,
          activeIcon: AppIconsV2.userActive,
          label: locale(context).tabbarProfile,
        ),
      ],
    );
  }
}
