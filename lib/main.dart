import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MePlay());
}


class MePlay extends StatelessWidget {
  // Map<String, Widget Function(BuildContext)> _routes = {
  //   '/': (BuildContext context) => BaseScreen(),
  //   '/favorites': (BuildContext context) => BaseScreen(initial: NavItems.fav),
  //   '/profile': (BuildContext context) => BaseScreen(initial: NavItems.profile),
  //   '/login': (BuildContext context) => LoginScreen(),
  //   '/tv': (BuildContext context) => ChannelListScreen(
  //
  //   ),
  //   '/radio': (BuildContext context) => ChannelListScreen(
  //
  //   ),
  // };
  //
  // Route<dynamic> _makeRoute(RouteSettings settings) {
  //   String name = settings.name;
  //   Object args = settings.arguments;
  //   // TODO: convert _routes to large if
  // }

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
      home: HomeScreen(),
    );
  }
}
