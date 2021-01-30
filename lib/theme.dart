import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AppColors {
  static get emptyTile {
    return Color.fromRGBO(255, 255, 255, 0.04 + Random().nextDouble() * 0.36);
  }
  static const megaPurple = Color.fromRGBO(88, 33, 122, 1);  // #58217A
  static const megaGreen = Color.fromRGBO(47, 140, 45, 1);  // #2F8C2D
  static const megaGray = Color.fromRGBO(198, 198, 198, 1);  // #C6C6C6
  static const white = Color.fromRGBO(255, 255, 255, 1);  // #FFFFFF
  static const black = Color.fromRGBO(0, 0, 0, 1);  // #000000
  static const bottomBar = Color.fromRGBO(247, 247, 247, 0.72);  // #F7F7F7 72%
  static const yellow = Color.fromRGBO(255, 204, 0, 1);  // #FFCC00
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
  static const homeBtns = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.bold, letterSpacing: -0.24,
      fontSize: 15, height: 20/15);
  static const logoTitle = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600, fontSize: 22, height: 28/22,
      letterSpacing: 0.35, color: AppColors.megaPurple);
}


class AppIcons {
  static final logo = SvgPicture.asset('assets/icons/logo.svg',width: 63, height: 72,);
  static final tv = SvgPicture.asset('assets/icons/tv.svg', width: 64, height: 64,);
  static final radio = SvgPicture.asset('assets/icons/radio.svg', width: 64, height: 64,);
  static final cinema = SvgPicture.asset('assets/icons/cinema.svg', width: 64, height: 64,);
  static final lock = SvgPicture.asset('assets/icons/lock.svg', width: 64, height: 64,);
  static final home = SvgPicture.asset('assets/icons/home.svg', width: 28, height: 28,);
  static final homeActive = SvgPicture.asset('assets/icons/home_active.svg', width: 28, height: 28,);
  static final star = SvgPicture.asset('assets/icons/star.svg', width: 28, height: 28,);
  static final starActive = SvgPicture.asset('assets/icons/star_active.svg', width: 28, height: 28,);
  static final user = SvgPicture.asset('assets/icons/user.svg', width: 28, height: 28,);
  static final userActive = SvgPicture.asset('assets/icons/user_active.svg', width: 28, height: 28,);
  static final profile = SvgPicture.asset('assets/icons/profile.svg', width: 50, height: 50,);
}
