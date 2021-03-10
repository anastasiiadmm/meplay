import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';
import 'profile.dart';
import 'channelList.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets/modals.dart';
import '../api_client.dart';
import '../utils/notification_helper.dart';
import '../utils/tz_helper.dart';


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

  static void inDevelopment(BuildContext context, {
    String title: 'Эта страница'
  }) {
    infoModal(
        context: context,
        title: Text(title),
        content: Text('Находится в разработке.')
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
    _initAsync();
  }

  Widget get _body {
    switch(_currentIndex) {
      case NavItems.profile:
        return ProfileScreen(user: _user, logout: _logoutDialog);
      case NavItems.home:
      default: return HomeScreen(
        watchTv: _watchTV,
        listenToRadio: () {NavItems.inDevelopment(context, title: 'Радио');},
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
      setState(() {
        _user = user;
      });
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

  Future<void> _showFavorites() async {
    List<Channel> favorites = await _user.filterFavorites(_channels);
    int index = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ChannelListScreen(
          channels: _channels,
          filtered: favorites,
          title: 'Избранное',
          selectedNavId: NavItems.fav,
        );
      },
    ));
    if (index != null) {
      _openPage(index, next: NavItems.tv);
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
          _showFavorites();
        }
        else if (index == NavItems.profile) {
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
    } on ApiException catch (e) {
      print(e.message);
      _channels = <Channel>[];
    }
  }

  Future<void> _loadUser() async {
    User user = await User.getUser();
    if (user != null) setState(() { _user = user; });
  }

  Future<void> _initNotifications() async {
    NotificationHelper helper = await NotificationHelper.initialize();
    RemoteMessage initial = await helper.getInitialMessage();
    if (initial != null) {
      // TODO: do something with it, maybe navigate somewhere.
    }
  }

  Future<void> _initTz() async {
    return TZHelper.init();
  }

  void _clearUser() async {
    User.clearUser();
    setState(() { _user = null; });
  }

  Future<void> _initAsync() async {
    await _loadUser();
    await _loadChannels();
    await _initNotifications();
    await _initTz();
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
  
  Future<bool> _logout()  async {
    _clearUser();
    await _loadChannels();
    setState(() { _currentIndex = NavItems.home; });
    return true;
  }
  
  void _logoutDialog() {
    asyncConfirmModal(
        context: context,
        title: Text('Выход'),
        content: Text('Вы уверены, что хотите выйти?'),
        action: _logout 
    );
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
        (_user == null) ? TextButton(
            onPressed: () { _login(NavItems.tv); },
            child: Text('Вход', style: AppFonts.appBarAction,)
        ) : TextButton(
          onPressed: _logoutDialog,
          child: Text('Выход', style: AppFonts.appBarAction,)
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
