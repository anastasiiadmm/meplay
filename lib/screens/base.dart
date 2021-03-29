import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';
import 'home.dart';
import 'login.dart';
import 'splash.dart';
import 'profile.dart';
import 'tvChannels.dart';
import 'tvFavorites.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets/modals.dart';
import '../utils/fcm_helper.dart';
import '../utils/local_notification_helper.dart';
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
  int _currentIndex;
  bool _loading = true;
  bool _asyncInitDone = false;
  bool _splashAnimationDone = false;
  bool _isSplashShowing = true;
  StreamSubscription _uniSub;

  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    _uniSub.cancel();
    super.dispose();
  }

  Future<Null> _initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      // TODO: navigate here somewhere
    } on PlatformException {
      // TODO: print error
    }

    _uniSub = getLinksStream().listen((String link) {
      // TODO: navigate here somewhere
    }, onError: (err) {
      // TODO: print error
    });
  }

  Widget get _body {
    switch(_currentIndex) {
      case NavItems.profile:
        return ProfileScreen(logout: _logoutDialog);
      case NavItems.home:
      default: return HomeScreen(
        watchTv: _watchTV,
        listenToRadio: () {NavItems.inDevelopment(context, title: 'Радио');},
      );
    }
  }

  Future<void> _login(int next) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
    setState(() {});
    if (await _isAuthenticated) _openPage(next);
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
    int index = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => TVFavoritesScreen(),
    ));
    if (index != null) {
      _openPage(index, next: NavItems.tv);
    }
  }

  void _onNavTap(int index) async {
    if (index == NavItems.home) {
      setState(() { _currentIndex = index; });
    } else {
      User user = await User.getUser();
      if (user == null) {
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

  Future<void> _initFcm() async {
    FCMHelper helper = await FCMHelper.initialize();
    RemoteMessage initial = await helper.getInitialMessage();
    if (initial != null) {
      // do something with it, maybe navigate somewhere.
    }
  }

  Future<void> _initNotifications() async {
    await LocalNotificationHelper.init();
  }

  Future<void> _initTz() async {
    return TZHelper.init();
  }

  Future<void> _loadUser() async {
    await User.loadUser();
  }

  Future<void> _clearUser() async {
    await User.clearUser();
    setState(() {});
  }

  Future<bool> get _isAuthenticated async {
    User user = await User.getUser();
    return user != null;
  }

  Future<void> _loadChannels() async {
    await Channel.loadChannels();
  }

  Future<void> _initAsync() async {
    await Future.wait([
      _initUniLinks(),
      _initTz().then((_) {
        Future.wait([
          _initNotifications(),
          _initFcm(),
        ]);
      }),
      _loadUser().then((_) {
        _loadChannels();
      }),
    ]);
    _asyncInitDone = true;
    _doneLoading();
  }

  void _doneLoading() {
    if(_asyncInitDone && _splashAnimationDone) {
      setState(() {
        _isSplashShowing = false;
      });
    }
  }

  void _splashShow() {
    _splashAnimationDone = true;
    _doneLoading();
  }

  void _splashHide() {
    _watchTV();
    Timer(Duration(milliseconds: 300), (){
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> _watchTV() async {
    int index = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => TVChannelsScreen(),
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

  Future<bool> _logout() async {
    await _clearUser();
    await _loadChannels();
    setState(() { _currentIndex = NavItems.home; });
    return true;
  }

  void _logoutDialog() {
    asyncConfirmModal(
      context: context,
      title: Text('Выход'),
      content: Text('Вы уверены, что хотите выйти?'),
      action: _logout,
    );
  }

  bool get _isHome {
    return (_currentIndex ?? 0) == NavItems.home;
  }

  Widget get _authBtn {
    return FutureBuilder<bool>(
      future: _isAuthenticated,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        bool isAuthenticated = snapshot.data;
        if(isAuthenticated) {
          return TextButton(
              onPressed: _logoutDialog,
              child: Text('Выход', style: AppFonts.appBarAction,)
          );
        } else {
          return TextButton(
            onPressed: () { _login(NavItems.tv); },
            child: Text('Вход', style: AppFonts.appBarAction,),
          );
        }
      },
    );
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
      actions: [
        if(_isHome) _authBtn,
      ],
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
      onShow: _splashShow,
      onHide: _splashHide,
      isSplashShowing: _isSplashShowing,
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
