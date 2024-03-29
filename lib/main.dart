import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'channel.dart';
import 'router.dart';
import 'utils/orientation_helper.dart';
import 'utils/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MePlay());
}

class MePlay extends StatelessWidget {
  Future<void> screenSetup() async {
    if (!await isTv()) {
      // Defaults
      OrientationHelper.forcePortrait();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSetup();
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
        title: 'MePlay',
        theme: ThemeData(fontFamily: 'Lato'),
        routes: routes,
        initialRoute: Routes.home,
        onGenerateRoute: router,
        navigatorKey: navigatorKey,
        locale: AppLocale.defaultChoice.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: [
          AppNavigatorObserver.instance,
        ],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
