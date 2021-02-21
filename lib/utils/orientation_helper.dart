import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


abstract class OrientationHelper {
  static Orientation force;
  
  static bool isFullscreen(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool get isForcingFullscreen {
    return force == Orientation.landscape;
  }
  
  static void allowAll() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    force = null;
  }

  static void forcePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    force = Orientation.portrait;
  }

  static void forceLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    force = Orientation.landscape;
  }

  static void toggleFullscreen() {
    if (isForcingFullscreen) {
      allowAll();
    } else {
      forceLandscape();
    }
  }
}
