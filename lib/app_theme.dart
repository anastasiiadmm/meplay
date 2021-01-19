import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';


class AppColors {
  static get emptyTile {
    return Color.fromRGBO(255, 255, 255, 0.04 + Random().nextDouble() * 0.36);
  }
  static const megaViolet = Color.fromRGBO(88, 33, 122, 1);  // #58217A
  static const megaGreen = Color.fromRGBO(47, 140, 45, 1);  // #2F8C2D
  static const megaGray = Color.fromRGBO(198, 198, 198, 1);  // #C6C6C6
  static const white = Color.fromRGBO(255, 255, 255, 1);  // #FFFFFF
  static const black = Color.fromRGBO(0, 0, 0, 1);  // #000000
  static const accentPink = Color.fromRGBO(255, 45, 85, 1);  // #FF2D55
  static const gray0 = Color.fromRGBO(250, 250, 247, 1);  // #FAFAF7
  static const gray5 = Color.fromRGBO(243, 243, 240, 1);  // #F3F3F0
  static const gray10 = Color.fromRGBO(234, 234, 228, 1);  // #EAEAE4
  static const gray20 = Color.fromRGBO(215, 215, 207, 1);  // #D7D7CF
  static const gray30 = Color.fromRGBO(191, 191, 182, 1);  // #BFBFB6
  static const gray40 = Color.fromRGBO(162, 162, 153, 1); // #A2A299
  static const gray50 = Color.fromRGBO(126, 126, 118, 1); // #7E7E76
  static const gray60 = Color.fromRGBO(83, 83, 78, 1); // #53534E
  static const gray70 = Color.fromRGBO(38, 38, 35, 1); // #262623
  static const gray80 = Color.fromRGBO(26, 25, 23, 1); // #1A1917
}


class AppFonts {
  static const homeButtons = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.bold, letterSpacing: -0.24,
      fontSize: 15, height: 20/15);

}


class AppIcons {

}
