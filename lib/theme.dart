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
  static const lightPurple = Color.fromRGBO(88, 86, 214, 1);  // #5856D6
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
  static const gray15 = Color.fromRGBO(224, 224, 214, 1);
  static const gray20 = Color.fromRGBO(215, 215, 207, 1);  // #D7D7CF
  static const gray30 = Color.fromRGBO(191, 191, 182, 1);  // #BFBFB6
  static const gray40 = Color.fromRGBO(162, 162, 153, 1);  // #A2A299
  static const gray50 = Color.fromRGBO(126, 126, 118, 1);  // #7E7E76
  static const gray60 = Color.fromRGBO(83, 83, 78, 1);  // #53534E
  static const gray70 = Color.fromRGBO(38, 38, 35, 1);  // #262623
  static const gray80 = Color.fromRGBO(26, 25, 23, 1);  // #1A1917
  static const transparentDark = Color.fromRGBO(26, 25, 23, 0.48);  // #1A1917 48%
  static const transparentGray = Color.fromRGBO(83, 83, 78, 0.48);  // #53534E 48%
  static const lockBg = Color.fromRGBO(191, 191, 182, 0.48);  // #BFBFB6 48%
  static const transparentBlack = Color.fromRGBO(0, 0, 0, 0.6);  // #000000 60%
  static const transparentLight = Color.fromRGBO(250, 250, 247, 0.85);  // #FAFAF7 85%

  static const gradientTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [transparentBlack, AppColors.transparent],
  );
  static const gradientBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [transparentBlack, AppColors.transparent],
  );
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
  static const appBarAction = TextStyle(fontFamily: 'SF Pro Text',
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
  static const videoTimer = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.gray5);
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
  static const videoTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 24, height: 1,
      letterSpacing: -0.24, color: AppColors.black,);
  static const lockText = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 12, height: 22/12,
      letterSpacing: -0.41, color: AppColors.black);
  static const lockLogin = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 12, height: 22/12,
      letterSpacing: -0.41, color: AppColors.lightPurple);
  static const profileAction = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.megaPurple);
  static const programTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray80);
  static const programTime = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray60);
  static const currentProgramTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray80);
  static const currentProgramTime = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray60);
  static const nowOnAir = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.accentPink);
  static const profileName = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray80);
  static const activePacketsTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.24, color: AppColors.gray60);
  static const activePacketList = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray80);
  static const packetListTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w600, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.white);
  static const packetName = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.bold, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray80);
  static const channelCount = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray60);
  static const packetPrice = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray80);
  static const videoSettingLabels = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w400, fontSize: 13, height: 18/13,
      letterSpacing: -0.24, color: AppColors.gray0);
  static const videoSettingValues = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w400, fontSize: 17, height: 22/17,
      letterSpacing: -0.41, color: AppColors.gray0);
}


class AppIcons {
  static final logo = SvgPicture.asset('assets/icons/logo.svg',width: 63, height: 72,);
  static final channelPlaceholder = SvgPicture.asset('assets/icons/logo.svg', width: 61.25, height: 70,);
  static final splash = SvgPicture.asset('assets/icons/logo.svg',width: 81, height: 93,);
  static final tv = SvgPicture.asset('assets/icons/tv.svg', width: 64, height: 64,);
  static final radio = SvgPicture.asset('assets/icons/radio.svg', width: 64, height: 64,);
  static final cinema = SvgPicture.asset('assets/icons/cinema.svg', width: 64, height: 64,);
  static final lockChannel = SvgPicture.asset('assets/icons/lock_gray.svg', width: 24, height: 24,);
  static final lockChannelLarge = SvgPicture.asset('assets/icons/lock_gray.svg', width: 101, height: 101,);
  static final lockAuth = SvgPicture.asset('assets/icons/lock_color.svg', width: 64, height: 64,);
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
  static final play = SvgPicture.asset('assets/icons/play.svg', width: 56, height: 56,);
  static final pause = SvgPicture.asset('assets/icons/pause.svg', width: 56, height: 56,);
  static final skipNext = SvgPicture.asset('assets/icons/skip_next.svg', width: 28, height: 28,);
  static final skipNextDis = SvgPicture.asset('assets/icons/skip_next_dis.svg', width: 28, height: 28,);
  static final skipPrev = SvgPicture.asset('assets/icons/skip_prev.svg', width: 28, height: 28,);
  static final skipPrevDis = SvgPicture.asset('assets/icons/skip_prev_dis.svg', width: 28, height: 28,);
  static final settings = SvgPicture.asset('assets/icons/settings.svg', width: 28, height: 28,);
  static final chromecast = SvgPicture.asset('assets/icons/chromecast.svg', width: 28, height: 28,);
  static final fullScreen = SvgPicture.asset('assets/icons/full_screen.svg', width: 28, height: 28,);
  static final smallScreen = SvgPicture.asset('assets/icons/small_screen.svg', width: 28, height: 28,);
  static final favAdd = SvgPicture.asset('assets/icons/fav_add.svg', width: 28, height: 28,);
  static final showProgram = SvgPicture.asset('assets/icons/program_open.svg', width: 44, height: 44,);
  static final hideProgram = SvgPicture.asset('assets/icons/program_close.svg', width: 44, height: 44,);
  static final pinkDot = Image.asset('assets/icons/pink_dot.png', width: 8, height: 8,);
  static final plus = SvgPicture.asset('assets/icons/plus.svg', width: 36, height: 36,);
  static final check = SvgPicture.asset('assets/icons/check_hex.svg', width: 31, height: 36,);
}


class Animations {
  static final progressIndicator = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray5),
    strokeWidth: 10,
  );
  static final modalProgressIndicator = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray40),
    strokeWidth: 7,
  );
}
