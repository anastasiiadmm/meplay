import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzInfo;
import 'package:timezone/timezone.dart';

class TZHelper {
  static Future<void> init() async {
    tzInfo.initializeTimeZones();

    String localZone = await FlutterNativeTimezone.getLocalTimezone();
    if (localZone.startsWith('GMT')) {
      String zoneName = 'Etc/GMT' + localZone[3];
      if (localZone[4] != '0') {
        zoneName += localZone[4];
      }
      zoneName += localZone[5];
      localZone = zoneName;
    }
    setLocalLocation(getLocation(localZone));
  }

  static TZDateTime now() {
    return TZDateTime.now(local);
  }

  static TZDateTime makeAware(DateTime dateTime) {
    return TZDateTime.from(dateTime, local);
  }

  static TZDateTime parse(String string) {
    return TZDateTime.parse(local, string);
  }
}
