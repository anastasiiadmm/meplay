import 'package:flutter/material.dart';
import 'package:me_play/screens/login.dart';
import 'home.dart';
import '../theme.dart';
import '../models.dart';


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
  User user;

  static const navItems = <NavItem>[
    NavItem.home,
    NavItem.favorites,
    NavItem.profile
  ];

  Widget get _body {
    switch(_currentItem) {
      case NavItem.home: return HomeScreen(onMenuTap: _onHomeTap);
      case NavItem.favorites: return null;
      case NavItem.profile: return null;
      case NavItem.tv: return null;
      case NavItem.radio: return null;
      case NavItem.cinema: return null;
      default: return HomeScreen(onMenuTap: _onHomeTap);
    }
  }

  void _login(int index, NavItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(
          afterLogin: (User user) {
            this.user = user;
            setState(() {
              _currentIndex = index;
              _currentItem = item;
            });
          },
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    var item = navItems[index];
    if(user == null && (item == NavItem.profile || item == NavItem.favorites)) {
      _login(index, item);
    } else {
      setState(() {
        _currentIndex = index;
        _currentItem = item;
      });
    }
  }

  void _onHomeTap(NavItem item) {
    setState(() {
      _currentIndex = null;
      _currentItem = item;
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
        onTap: _onNavTap,
        currentIndex: _currentIndex ?? 0,
        items: [
          BottomNavigationBarItem(
            icon: AppIcons.home,
            activeIcon: _currentIndex != null
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
      ),
    );
  }
}
