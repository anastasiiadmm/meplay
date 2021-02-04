import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


final rnd = Random();

class AppColors {
  static get emptyTile {
    double rand = rnd.nextDouble();
    double opacity;
    if (rand <= 0.1)
      opacity = 0.04 + rnd.nextDouble() * 0.06;
    else if (rand <= 0.7)
      opacity = 0.07 + rnd.nextDouble() * 0.23;
    else if (rand <= 0.9)
      opacity = 0.17 + rnd.nextDouble() * 0.23;
    else
      opacity = 0.27 + rnd.nextDouble() * 0.13;
    return Color.fromRGBO(255, 255, 255, opacity);
  }
  static const megaPurple = Color.fromRGBO(88, 33, 122, 1);  // #58217A
  static const disabledPurple = Color.fromRGBO(114, 73, 137, 1);  // #724989
  static const megaGreen = Color.fromRGBO(47, 140, 45, 1);  // #2F8C2D
  static const megaGray = Color.fromRGBO(198, 198, 198, 1);  // #C6C6C6
  static const white = Color.fromRGBO(255, 255, 255, 1);  // #FFFFFF
  static const black = Color.fromRGBO(0, 0, 0, 1);  // #000000
  static const transparent = Color.fromRGBO(0, 0, 0, 0);  // #000000
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
  static const transparentDark = Color.fromRGBO(26, 25, 23, 0.48); // #1A1917 48%
}


class AppFonts {
  static const homeBtns = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.bold, letterSpacing: -0.24,
      fontSize: 15, height: 20/15, color: AppColors.gray70);
  static const logoTitle = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600, fontSize: 22, height: 28/22,
      letterSpacing: 0.35, color: AppColors.megaPurple);
  static const splashTitle = TextStyle(fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600, fontSize: 34, height: 41/34,
      letterSpacing: 0.4, color: AppColors.megaPurple);
  static const backBtn = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray0);
  static const screenTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray0);
  static const formBtn = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.white);
  static const formBtnDisabled = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray10);
  static const userAgreement = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray0);
  static const userAgreementLink = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray0,
      decoration: TextDecoration.underline);
  static const smsTimer = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.gray10);
  static const channelName = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.black);
  static const programName = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 11, height: 13/11,
      letterSpacing: 0.07, color: AppColors.gray60);
  static const smsTimerLink = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.gray10,
      decoration: TextDecoration.underline);
  static const loginInputHint = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray30);
  static const loginInputText = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray70);
  static const loginError = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.bold, fontSize: 17, height: 22/17,
      letterSpacing: -0.31, color: AppColors.accentPink);
  static const searchInputHint = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray50);
  static const searchInputText = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray10);
}


class AppIcons {
  static final logo = SvgPicture.asset('assets/icons/logo.svg',width: 63, height: 72,);
  static final channelPlaceholder = SvgPicture.asset('assets/icons/logo.svg', width: 61.25, height: 70,);
  static final splash = SvgPicture.asset('assets/icons/logo.svg',width: 81, height: 93,);
  static final tv = SvgPicture.asset('assets/icons/tv.svg', width: 64, height: 64,);
  static final radio = SvgPicture.asset('assets/icons/radio.svg', width: 64, height: 64,);
  static final cinema = SvgPicture.asset('assets/icons/cinema.svg', width: 64, height: 64,);
  static final lockSmall = SvgPicture.asset('assets/icons/lock_small.svg', width: 24, height: 24,);
  static final lockBig = SvgPicture.asset('assets/icons/lock_big.svg', width: 64, height: 64,);
  static final home = SvgPicture.asset('assets/icons/home.svg', width: 28, height: 28,);
  static final homeActive = SvgPicture.asset('assets/icons/home_active.svg', width: 28, height: 28,);
  static final star = SvgPicture.asset('assets/icons/star.svg', width: 28, height: 28,);
  static final starActive = SvgPicture.asset('assets/icons/star_active.svg', width: 28, height: 28,);
  static final user = SvgPicture.asset('assets/icons/user.svg', width: 28, height: 28,);
  static final userActive = SvgPicture.asset('assets/icons/user_active.svg', width: 28, height: 28,);
  static final profile = SvgPicture.asset('assets/icons/profile.svg', width: 50, height: 50,);
  static final back = SvgPicture.asset('assets/icons/back.svg', width: 12, height: 21,);
  static final search = SvgPicture.asset('assets/icons/search.svg', width: 28, height: 28,);
  static final searchInput = SvgPicture.asset('assets/icons/search_input.svg', width: 16, height: 16,);
}
