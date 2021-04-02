import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:me_play/screens/player.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/tvChannels.dart';
import 'screens/tvFavorites.dart';
import 'models.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MePlay());
}


class MePlay extends StatelessWidget {
  Route<dynamic> _makeRoute(RouteSettings settings) {
    String name = settings.name;
    if(name == '/login') return MaterialPageRoute<User>(
      builder: (BuildContext context) => LoginScreen(),
      settings: settings,
    );
    else if(name.startsWith('/tv/')) {
      List<String> parts = name.split('/');
      int id = int.tryParse(parts[2]);
      return MaterialPageRoute(
        builder: (BuildContext context) {
          String currentName = ModalRoute.of(context).settings.name;
          if(currentName.startsWith('/tv/')) {
            Navigator.of(context).pop();
          }
          return PlayerScreen(channelId: id);
        },
        settings: settings,
      );
    }
    else return null;
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

      // "static" routes (not containing variables and not returning anything)
      routes: {
        '/': (BuildContext context) => HomeScreen(),
        '/profile': (BuildContext context) => ProfileScreen(),
        '/tv': (BuildContext context) => TVChannelsScreen(),
        '/favorites': (BuildContext context) => TVFavoritesScreen(),
        '/favorites/tv': (BuildContext context) => TVFavoritesScreen(),

        // TODO:
        // '/radio': (BuildContext context) => null,
        // '/favorites/radio': (BuildContext context) => null,
      },

      // dynamic routes (containing variables or returning something)
      onGenerateRoute: _makeRoute,
      initialRoute: '/',
    );
  }
}
