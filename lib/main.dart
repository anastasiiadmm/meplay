import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:me_play/utils/notifications.dart';
import 'screens/base.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initMessages();
  runApp(MePlay());
}

void initMessages() async {
  await FirebaseHelper.init();
  FirebaseHelper.sendToken();
  FirebaseHelper.receiveMessages();
}


class MePlay extends StatelessWidget {
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
      home: BaseScreen(),
    );
  }
}
