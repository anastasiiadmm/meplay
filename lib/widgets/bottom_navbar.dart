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
      backgroundColor: AppColors.navBg,
      onTap: (int index) => _onNavTap(context, index),
      currentIndex: NavItems.hasIndex(showIndex) ? showIndex : 0,
      selectedLabelStyle: AppFonts.tabbar,
      unselectedLabelStyle: AppFonts.tabbar,
      selectedItemColor: AppColors.textSecondary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home_null,
          activeIcon: NavItems.hasIndex(showIndex)
              ? AppIcons.home_active_null
              : AppIcons.home_null,
          label: locale(context).tabbarMain,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.favorite_null,
          activeIcon: AppIcons.favorite_active_null,
          label: locale(context).tabbarFavorites,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user_null,
          activeIcon: AppIcons.user_active_null,
          label: locale(context).tabbarProfile,
        ),
      ],
    );
  }
}
