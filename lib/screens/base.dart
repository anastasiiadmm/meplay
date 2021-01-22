import 'package:flutter/material.dart';
import 'home.dart';
import '../app_theme.dart';


class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}


enum NavItem {
  home,
  favorites,
  profile,
  tv,
  radio,
  cinema,
}


class _BaseScreenState extends State<BaseScreen> {
  // used by bottom navbar
  int _currentIndex = 0;
  NavItem _currentItem = NavItem.home;

  static const indexItems = <NavItem>[NavItem.home, NavItem.favorites, NavItem.profile];

  Widget get _body {
    switch(_currentItem) {
      case NavItem.home: return HomeScreen();
      case NavItem.favorites: return null;
      case NavItem.profile: return null;
      case NavItem.tv: return null;
      case NavItem.radio: return null;
      case NavItem.cinema: return null;
      default: return HomeScreen();
    }
  }

  void _onScreenSwitch(int index) {
    setState(() {
      _currentIndex = index;
      _currentItem = indexItems[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      extendBody: true,
      body: _body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onScreenSwitch,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: AppIcons.home, activeIcon: AppIcons.homeActive, label: 'Главная'),
          BottomNavigationBarItem(icon: AppIcons.star, activeIcon: AppIcons.starActive, label: 'Избранное'),
          BottomNavigationBarItem(icon: AppIcons.user, activeIcon: AppIcons.userActive, label: 'Профиль'),
        ],
      ),
    );
  }
}
