import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/tvChannels.dart';
import 'screens/tvFavorites.dart';
import 'screens/radioChannels.dart';
import 'screens/radioFavorites.dart';
import 'screens/player.dart';
import 'models.dart';


// static routes which do not accept variables or have a return type
final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => HomeScreen(),
  '/profile': (BuildContext context) => ProfileScreen(),
  '/tv': (BuildContext context) => TVChannelsScreen(),
  '/radio': (BuildContext context) => RadioChannelsScreen(),
  '/favorites': (BuildContext context) => TVFavoritesScreen(),
  '/favorites/tv': (BuildContext context) => TVFavoritesScreen(),
  '/favorites/radio': (BuildContext context) => RadioFavoritesScreen(),
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
      builder: (BuildContext context) => PlayerScreen(
        channelId: id,
        channelType: ChannelType.tv,
      ),
      settings: settings,
    );
  }
  else if(name.startsWith('/radio/')) {
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
