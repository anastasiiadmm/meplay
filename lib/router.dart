import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/tvChannels.dart';
import 'screens/tvFavorites.dart';
import 'screens/player.dart';
import 'models.dart';


// static routes which do not accept variables or have a return type
final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => HomeScreen(),
  '/profile': (BuildContext context) => ProfileScreen(),
  '/tv': (BuildContext context) => TVChannelsScreen(),
  // '/radio': (BuildContext context) => null,  // TODO

  '/favorites': (BuildContext context) => TVFavoritesScreen(),
  '/favorites/tv': (BuildContext context) => TVFavoritesScreen(),
  // '/favorites/radio': (BuildContext context) => null,  // TODO
};


// dynamic routes which accept variables or have specific return type
Route<dynamic> router(RouteSettings settings) {
  String name = settings.name;
  if(name == '/login') {
    return MaterialPageRoute<User>(
      builder: (BuildContext context) => LoginScreen(),
      settings: settings,
    );
  }
  else if(name.startsWith('/tv/')) {
    List<String> parts = name.split('/');
    int id = int.tryParse(parts[2]);
    return MaterialPageRoute(
      builder: (BuildContext context) => PlayerScreen(channelId: id),
      settings: settings,
    );
  }
  // TODO
  // else if(name.startsWith('/radio/')) {
  //   List<String> parts = name.split('/');
  //   int id = int.tryParse(parts[2]);
  //   return MaterialPageRoute(
  //     builder: (BuildContext context) => PlayerScreen(channelId: id),
  //     settings: settings,
  //   );
  // }
  else return null;
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'App Nav Key',
);


class HistoryManager extends NavigatorObserver {
  List<Route> _history = [];

  List<Route> get history => _history;

  Route get currentRoute => _history.length > 0
      ? _history[_history.length - 1]
      : null;

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    print('push ${route.settings}');
    _history.add(route);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    print('pop ${route.settings}');
    _history.removeLast();
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    super.didRemove(route, previousRoute);
    print('remove ${route.settings}');
    _history.remove(route);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('replace ${oldRoute?.settings} with ${newRoute?.settings}');
    if(oldRoute != null) {
      int index = _history.indexOf(oldRoute);
      if(index > 0) _history.removeAt(index);
      if(newRoute != null) _history.insert(index, newRoute);
    }
  }
}


final historyManager = HistoryManager();
