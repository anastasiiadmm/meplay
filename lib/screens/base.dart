import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';
import 'channelList.dart';
import '../theme.dart';
import '../models.dart';
import '../api_client.dart';


class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}


const int _homeIndex = 0;
const int _favoritesIndex = 1;
const int _profileIndex = 2;


class _BaseScreenState extends State<BaseScreen> {
  // used by bottom navbar
  int _currentIndex;
  bool _loading = true;
  User _user;
  void Function() _splashHide;
  List<Channel> _channels;

  void initState() {
    super.initState();
    _initData();
  }

  Widget get _body {
    switch(_currentIndex) {
      case _homeIndex:
      default: return HomeScreen(
        watchTv: _watchTV,
        listenToRadio: () {_inDevelopment('Радио');},
        watchCinema: () {_inDevelopment('Кинотеатр');},
      );
    }
  }

  Future<void> _login(int index) async {
    User user = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
    if (user != null) {
      _user = user;
      await _reloadChannels();
      _onNavTap(index);
    }
  }

  void _onNavTap(int index) {
    if (index == _homeIndex) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      if (_user == null) {
        _login(index);
      } else {
        if (index == _favoritesIndex) {
          _inDevelopment('Избранное');
        } else if (index == _profileIndex) {
          _inDevelopment('Профиль');
        } else {
          _inDevelopment('Эта страница');
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if(_currentIndex == _homeIndex) return true;
    setState(() {
      _currentIndex = 0;
    });
    return false;
  }

  Future<void> _reloadChannels() async {
    try {
      _channels = await ApiClient.getChannels(_user);
    } on ApiException {
      _channels = <Channel>[];
    }
  }

  Future<void> _restoreUser() async {
    // TODO: try to restore users phone and password from persistence, then authenticate him
  }

  Future<void> _initData() async {
    await _restoreUser();
    await _reloadChannels();
    _doneLoading();
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
    _watchTV();
    Timer(Duration(milliseconds: 500), (){
      setState(() {
        _loading = false;
      });
    });
  }

  void _inDevelopment(String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text('Находится в разработке.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Закрыть')
          )
        ],
      ),
    );
  }

  Future<void> _watchTV() async {
    int index = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ChannelListScreen(
          channels: _channels,
          title: 'ТВ Каналы',
        ),
      ),
    );
    if (index != null) {
      _onNavTap(index);
    }
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
              activeIcon: AppIcons.homeActive,
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
