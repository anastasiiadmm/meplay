import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:me_play/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


class NavItems {
  static const int home = 0;
  static const int fav = 1;
  static const int profile = 2;
  static const int login = 3;
  static const int tv = 4;
  static const int radio = 5;
  static const int cinema = 6;

  static void inDevelopment(BuildContext context, {String title: 'Эта страница'}) {
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
}


class _BaseScreenState extends State<BaseScreen> {
  // used by bottom navbar
  int _currentIndex;
  bool _loading = true;
  User _user;
  void Function() _splashHide;
  List<Channel> _channels;

  void initState() {
    super.initState();
    _init();
  }

  Widget get _body {
    switch(_currentIndex) {
      case NavItems.profile:
        return ProfileScreen(user: _user, logout: _logout);
      case NavItems.home:
      default: return HomeScreen(
        watchTv: _watchTV,
        listenToRadio: () {NavItems.inDevelopment(context, title: 'Радио');},
        watchCinema: () {NavItems.inDevelopment(context, title: 'Кинотеатр');},
      );
    }
  }

  Future<void> _login(int next) async {
    User user = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
    if (user != null) {
      _user = user;
      await _loadChannels();
      _openPage(next);
    }
  }
  
  void _openPage(int index, {int next: NavItems.home}) {
    if (index == NavItems.login) {
      _login(next);
    } else if (index == NavItems.tv) {
      _watchTV();
    } else {
      _onNavTap(index);
    }
  }

  void _onNavTap(int index) {
    if (index == NavItems.home) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      if (_user == null) {
        _login(index);
      } else {
        if (index == NavItems.fav) {
          NavItems.inDevelopment(context, title: 'Избранное');
        } else if (index == NavItems.profile) {
          setState(() {
            _currentIndex = index;
          });
        } else {
          NavItems.inDevelopment(context);
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if(_currentIndex == NavItems.home) return true;
    setState(() {
      _currentIndex = 0;
    });
    return false;
  }

  Future<void> _loadChannels() async {
    try {
      _channels = await ApiClient.getChannels(_user);
    } on ApiException {
      _channels = <Channel>[];
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      String userInfo = prefs.getString('user');
      _user =  User.fromJson(jsonDecode(userInfo));
    }
  }

  Future<void> _init() async {
    await _loadUser();
    await _loadChannels();
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
      _openPage(index, next: NavItems.tv);
    }
  }

  void _back() {
    if (_currentIndex == NavItems.home) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentIndex = NavItems.home;
      });
    }
  }

  Widget get _appBarTitle {
    String text;
    if (_currentIndex == NavItems.profile) {
      text = 'Личный кабинет';
    } else if (_currentIndex == NavItems.fav) {
      text = 'Избранное';
    }
    if (text != null) {
      return Text(text, style: AppFonts.screenTitle);
    }
    return null;
  }
  
  void _logout() {
    setState(() {
      _user = null;
      _currentIndex = NavItems.home;
    });
    _loadChannels();
  }

  bool get _isHome {
    return (_currentIndex ?? 0) == NavItems.home;
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: _isHome
        ? AppColors.transparent 
        : AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: _isHome ? null : IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      actions: _isHome ? [
        TextButton(
          onPressed: _logout,
          child: Text('Выйти', style: AppFonts.appBarAction,)
        ),
      ] : [],
      title: _appBarTitle,
      centerTitle: true,
    );
  }

  Widget get _bottomNavBar {
    return BottomNavigationBar(
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
    );
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
        appBar: _appBar,
        extendBody: _isHome,
        extendBodyBehindAppBar: _isHome,
        body: _body,
        bottomNavigationBar: _bottomNavBar,
      ),
    );
  }
}

// TODO: выход в аппбаре справа на главной. По выходу тупо удалять username и пароль и очищать юзера в base.dart.
