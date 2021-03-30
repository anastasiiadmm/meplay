import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/tvChannels.dart';
import 'screens/tvFavorites.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MePlay());
}


class MePlay extends StatelessWidget {
  final Map<String, Widget Function(BuildContext)> routes = {
    '/': (BuildContext context) => HomeScreen(),
    '/login': (BuildContext context) => LoginScreen(),
    '/profile': (BuildContext context) => ProfileScreen(),
    '/tv': (BuildContext context) => TVChannelsScreen(),
    '/favorites': (BuildContext context) => TVFavoritesScreen(),
    // TODO:
    // '/radio': (BuildContext context) => null,
    // '/favorites/tv'
    // '/favorites/radio': (BuildContext context) => null,
  };

  Route<dynamic> _makeRoute(RouteSettings settings) {
    String name = settings.name;
    Object args = settings.arguments;
    Widget Function(BuildContext) builder;
    print('Route: $name, args: $args');
    if(routes.containsKey(name)) {
      builder = routes[name];
    } else {
      // TODO check for dynamic routes like /tv/1, /tv/2, ... etc.
      builder = routes['/'];
    }
    return MaterialPageRoute(builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    // Defaults
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    // Should be:
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: AppColors.transparent));
    // but due to https://github.com/flutter/flutter/issues/62412
    // and https://github.com/flutter/flutter/issues/40974
    // and https://github.com/flutter/flutter/issues/34678
    // note: https://github.com/flutter/flutter/issues/34678#issuecomment-536028077
    // does not work, so
    SystemChrome.setEnabledSystemUIOverlays([]);
    // and no SystemOverlayStyle, as it's ignored by hidden overlays.

    return MaterialApp(
      title: 'Me Play',
      theme: ThemeData(fontFamily: 'SF Pro Text'),
      onGenerateRoute: _makeRoute,
      initialRoute: '/',
    );
  }
}
