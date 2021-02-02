import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';
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
  int _currentIndex;
  NavItem _currentItem = NavItem.home;
  bool _loading = true;
  User _user;
  void Function() _splashHide;
  List<Channel> _channels;

  void initState() {
    super.initState();
    _loadChannels();
  }

  static const navItems = <NavItem>[
    NavItem.home,
    NavItem.favorites,
    NavItem.profile,
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
            this._user = user;
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
    if(_user == null && item != NavItem.home) {
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

  Future<bool> _onWillPop() async {
    if(_currentItem == NavItem.home) return true;
    setState(() {
      _currentItem = NavItem.home;
      _currentIndex = 0;
    });
    return false;
  }

  Future<void> _loadChannels() async {
    Timer(Duration(seconds: 5), () {
      setState(() {
        _channels = [];
        _doneLoading();
      });
    });
  }

  void _doneLoading() {
    if(_channels != null && _splashHide != null) {
      _splashHide();
    }
  }

  void _afterSplashShow(void Function() splashHide) {
    _splashHide = splashHide;
    _doneLoading();
  }

  void _afterSplashHide() {
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? SplashScreen(
      afterShow: _afterSplashShow,
      afterHide: _afterSplashHide,
    ) : WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
      ),
    );
  }
}
