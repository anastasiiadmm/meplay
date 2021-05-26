import 'dart:async';
import 'package:flutter/material.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../utils/fcm_helper.dart';
import '../utils/local_notification_helper.dart';
import '../utils/tz_helper.dart';
import '../utils/deeplink_helper.dart';
import '../widgets/modals.dart' as modals;
import '../widgets/bottomNavBar.dart';
import '../inherited/auth_notifier.dart';
import '../theme.dart';
import '../models.dart';
import 'splash.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;  // if splash is present on screen
  bool _asyncInitDone = false;
  bool _splashAnimationDone = false;
  bool _isSplashShowing = true;  // if splash animates from hidden to visible or back
  DeeplinkHelper _deeplinkHelper;

  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    _deeplinkHelper.dispose();
    super.dispose();
  }

  Future<void> _initAsync() async {
    await User.getUser();
    await Future.wait([
      Channel.loadTv(),
      Channel.loadRadio(),
    ]);
    await TZHelper.init();
    _deeplinkHelper = DeeplinkHelper.instance;
    await _deeplinkHelper.checkInitialLink();
    await LocalNotificationHelper.init();
    FCMHelper helper = await FCMHelper.initialize();
    await helper.checkInitialMessage();
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
    if(!_deeplinkHelper.navigated) _watchTV();
    Timer(Duration(milliseconds: 300), (){
      setState(() { _loading = false; });
    });
  }

  void _watchTV() {
    Navigator.of(context).pushNamed('/tv');
  }

  void _listenRadio() {
    Navigator.of(context).pushNamed('/radio');
  }

  Widget get _body => Container();

  Future<void> _login() async {
    User user = await Navigator.of(context).pushNamed('/login');
    setState(() {});  // refresh the state for the login/logout button
    if (user != null) _watchTV();
  }

  Future<void> _logout() async {
    await User.clearUser();
    await Future.wait([
      Channel.loadTv(),
      Channel.loadRadio(),
    ]);
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
          User user = AuthNotifier.of(context).user;
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

  void _openNotifications() {
    // TODO
  }

  int get _notificationsCount {
    int count = 99; // TODO
    if(count > 99) count = 99;
    return count;
  }

  Widget get _notificationsBtn {
    return SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: AppColorsV2.iconBg,
          type: MaterialType.circle,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            child: Stack(
              children: [
                Center(
                  child: AppIconsV2.bell,
                ),
                if(_notificationsCount > 0) Positioned(
                  top: 8,
                  right: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColorsV2.purple,
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: Text(
                          _notificationsCount.toString(),
                          style: AppFontsV2.notificationCount,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: _openNotifications, // TODO-x
          ),
        ),
      );
  }

  Widget get _appBar {
    return PreferredSize(
      preferredSize: Size(double.infinity, 68),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppImages.logoTop,
            _notificationsBtn,
          ],
        ),
      ),
    );
  }

  Widget get _bottomNavBar => BottomNavBar(showIndex: 0);

  @override
  Widget build(BuildContext context) {
    return _loading ? SplashScreen(
      onShow: _splashShow,
      onHide: _splashHide,
      isVisible: _isSplashShowing,
    ) : Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      appBar: _appBar,
      body: Center(child: AppImages.logoTop,),
      bottomNavigationBar: null,
    );
  }
}
