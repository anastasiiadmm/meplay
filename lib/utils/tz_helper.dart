import 'package:timezone/data/latest.dart' as tzInfo;
import 'package:timezone/timezone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';


class TZHelper {
  static Future<void> init() async {
    String localZone = await FlutterNativeTimezone.getLocalTimezone();

    tzInfo.initializeTimeZones();
    setLocalLocation(getLocation(localZone));
  }

  static TZDateTime now() {
    return TZDateTime.now(local);
  }

  static TZDateTime fromNaive(DateTime dateTime) {
    return TZDateTime.from(dateTime, local);
  }
}
