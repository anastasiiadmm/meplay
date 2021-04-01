import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../utils/fcm_helper.dart';
import '../utils/local_notification_helper.dart';
import '../utils/tz_helper.dart';
import 'login.dart';
import 'splash.dart';
import 'tvChannels.dart';
import '../widgets/modals.dart' as modals;
import '../widgets/bottomNavBar.dart';
import '../inherited/auth_notifier.dart';
import '../theme.dart';
import '../models.dart';



class HomeHexGrid extends StatelessWidget {
  final gridSize = HexGridSize(7, 5);
  final logoTile = HexGridPoint(2, 2);
  final tvButton = HexGridPoint(3, 1);
  final radioButton = HexGridPoint(3, 2);
  final void Function() watchTV;
  final void Function() listenRadio;

  HomeHexGrid({Key key, this.watchTV, this.listenRadio})
      : super(key: key);

  HexagonWidget _tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == logoTile) {
      color = AppColors.gray5;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: AppIcons.logo,
          ),
          Text('MePlay', style: AppFonts.logoTitle,),
        ],
      );
    } else if (point == tvButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: watchTV,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: AppIcons.tv,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            ),
            Text('ТВ КАНАЛЫ', style: AppFonts.homeBtns,),
          ],
        ),
      );
    } else if (point == radioButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: listenRadio,
        child: Opacity(
          opacity: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                child: AppIcons.radio,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
              Text('РАДИО', style: AppFonts.homeBtns,),
            ],
          ),
        ),
      );
    } else {
      color = AppColors.emptyTile;
    }
    return HexagonWidget.template(color: color, child: content);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Center(
            child: HexagonOffsetGrid.oddPointy(
              columns: gridSize.cols,
              rows: gridSize.rows,
              symmetrical: true,
              color: AppColors.transparent,
              hexagonPadding: 8,
              hexagonBorderRadius: 15,
              hexagonWidth: 174,
              buildHexagon: _tileBuilder,
            ),
          ),
        ),
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;  // if splash is present on screen
  bool _asyncInitDone = false;
  bool _splashAnimationDone = false;
  bool _isSplashShowing = true;  // if splash animates from hidden to visible or back
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

  Future<void> _initUniLinks() async {
    // TODO: make deeplink helper
    //  prevent opening deeplink routes if it is current or invalid.
    //  close old channel if one opened.

    try {
      String initialLink = await getInitialLink();
      if(initialLink != null) {
        print(initialLink);
        String link = initialLink.replaceAll('http://teleclick.kg/deeplinks', '');
        link = link.replaceAll('https://teleclick.kg/deeplinks', '');
        link = link.replaceAll('meplay://teleclick.kg', '');
        if(link == '') link = '/';
        Navigator.of(context).pushNamed(link);
      }
    } on PlatformException {
      // TODO: print error
    }

    _uniSub = getLinksStream().listen((String link) {
      print(link);
      link = link.replaceAll('http://teleclick.kg/deeplinks', '');
      link = link.replaceAll('https://teleclick.kg/deeplinks', '');
      link = link.replaceAll('meplay://teleclick.kg', '');
      if(link == '') link = '/';
      Navigator.of(context).pushNamed(link);
    }, onError: (err) {
      // TODO: print error
    });
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
    await User.getUser();
  }

  Future<void> _clearUser() async {
    await User.clearUser();
  }

  Future<void> _loadChannels() async {
    await Channel.loadChannels();
  }

  Future<void> _initAsync() async {
    await Future.wait([
      _initUniLinks(),
      _initTz().then((_) => Future.wait([
        _initNotifications(),
        _initFcm(),
      ])),
      _loadUser().then((_) => _loadChannels())
    ]);
    _asyncInitDone = true;
    _doneLoading();
  }

  void _doneLoading() {
    if(_asyncInitDone && _splashAnimationDone) {
      setState(() { _isSplashShowing = false; });
    }
  }

  void _splashShow() {
    _splashAnimationDone = true;
    _doneLoading();
  }

  void _splashHide() {
    _watchTV();
    Timer(Duration(milliseconds: 300), (){
      setState(() { _loading = false; });
    });
  }

  void _watchTV() {
    Navigator.of(context).pushNamed('/tv');
  }

  void _listenRadio() {
    modals.inDevelopment(context, title: 'Радио');
  }

  Widget get _body => HomeHexGrid(
    watchTV: _watchTV,
    listenRadio: _listenRadio,
  );

  Future<void> _login() async {
    User user = await Navigator.of(context).pushNamed('/login');
    setState(() {});  // refresh the state for the login/logout button
    if (user != null) _watchTV();
  }

  Future<void> _logout() async {
    await _clearUser();
    await _loadChannels();
    setState(() {});  // refresh the state for the login/logout button
  }

  void _logoutDialog() {
    modals.confirmModal(
      context: context,
      title: Text('Выход'),
      content: Text('Вы уверены, что хотите выйти?'),
      action: _logout,
    );
  }

  Widget get _authBtn {
    return AuthNotifier(
      child: Builder(
        builder: (BuildContext context) {
          User user = AuthNotifier.of(context);
          return user == null ? TextButton(
            onPressed: _login,
            child: Text('Вход', style: AppFonts.appBarAction),
          ) : TextButton(
            onPressed: _logoutDialog,
            child: Text('Выход', style: AppFonts.appBarAction),
          );
        },
      ),
      notifier: User.userNotifier,
    );
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [ _authBtn, ],
    );
  }

  Widget get _bottomNavBar => BottomNavBar(showIndex: 0);

  @override
  Widget build(BuildContext context) {
    return _loading ? SplashScreen(
      onShow: _splashShow,
      onHide: _splashHide,
      isSplashShowing: _isSplashShowing,
    ) : Scaffold(
      backgroundColor: AppColors.megaPurple,
      appBar: _appBar,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
