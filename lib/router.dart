import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/notifications.dart';
import 'screens/settings.dart';
import 'screens/tv_channels.dart';
import 'screens/radio_channels.dart';
import 'screens/favorites.dart';
import 'screens/player.dart';
import 'screens/intro.dart';
import 'models.dart';


abstract class Routes {
  static const home = '/';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const tv = '/tv';
  static const radio = '/radio';
  static const favorites = '/favorites';
  static const login = '/login';
  static const tvChannel = '/tv/';  // match this with String.startsWith
  static const radioChannel = '/radio/';  // match this with String.startsWith
  static const intro = '/intro';

  static const ROUTES = [home, profile, settings, notifications,
    tv, radio, favorites, login, intro];
  static const MATCH_ROUTES = [tvChannel, radioChannel];
  static bool allowed(String route) {
    return ROUTES.contains(route)
        || MATCH_ROUTES.any((r) => route.startsWith(r));
  }
}


// static routes which do not accept variables or have a return type
final Map<String, WidgetBuilder> routes = {
  Routes.home: (BuildContext context) => HomeScreen(),
  Routes.profile: (BuildContext context) => ProfileScreen(),
  Routes.notifications: (BuildContext context) => NotificationListScreen(),
  Routes.settings: (BuildContext context) => SettingsScreen(),
  Routes.tv: (BuildContext context) => TVChannelsScreen(),
  Routes.radio: (BuildContext context) => RadioChannelsScreen(),
  Routes.favorites: (BuildContext context) => FavoritesScreen(),
  Routes.intro: (BuildContext context) => IntroScreen(),
};


// dynamic routes which accept variables or have specific return type
Route<dynamic> router(RouteSettings settings) {
  String name = settings.name;
  if(name == Routes.login) {
    return MaterialPageRoute<User>(
      builder: (BuildContext context) => LoginScreen(),
      settings: settings,
    );
  }
  else if(name.startsWith(Routes.tvChannel)) {
    List<String> parts = name.split('/');
    int id = int.tryParse(parts[2]);
    return MaterialPageRoute(
      builder: (BuildContext context) => PlayerScreen(
        channelId: id,
        channelType: ChannelType.tv,
      ),
      settings: settings,
    );
  }
  else if(name.startsWith(Routes.radioChannel)) {
    List<String> parts = name.split('/');
    int id = int.tryParse(parts[2]);
    return MaterialPageRoute(
      builder: (BuildContext context) => PlayerScreen(
        channelId: id,
        channelType: ChannelType.radio,
      ),
      settings: settings,
    );
  }
  else return null;
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'App Nav Key',
);


class AppNavigatorObserver extends NavigatorObserver {
  static AppNavigatorObserver _instance;

  AppNavigatorObserver._();

  static AppNavigatorObserver get instance {
    if(_instance == null) _instance = AppNavigatorObserver._();
    return _instance;
  }

  Route<dynamic> _currentRoute;

  Route<dynamic> get currentRoute => _currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    _currentRoute = route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    _currentRoute = previousRoute;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    _currentRoute = previousRoute;
  }

  @override
  void didReplace({ Route<dynamic> newRoute, Route<dynamic> oldRoute }) {
    if(oldRoute == _currentRoute) {
      _currentRoute = newRoute;
    }
  }
}
