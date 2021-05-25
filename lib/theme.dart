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

  static const megaPurple = Color.fromRGBO(88, 33, 122, 1); // #58217A
  static const lightPurple = Color.fromRGBO(114, 73, 137, 1); // #724989
  static const darkPurple = Color.fromRGBO(95, 36, 159, 1); // #5F249F
  static const bluePurple = Color.fromRGBO(88, 86, 214, 1); // #5856D6
  static const megaGreen = Color.fromRGBO(47, 140, 45, 1); // #2F8C2D
  static const megaGray = Color.fromRGBO(198, 198, 198, 1); // #C6C6C6
  static const white = Color.fromRGBO(255, 255, 255, 1); // #FFFFFF
  static const black = Color.fromRGBO(0, 0, 0, 1); // #000000
  static const transparent = Color.fromRGBO(0, 0, 0, 0); // #000000
  static const bottomBar = Color.fromRGBO(247, 247, 247, 0.72); // #F7F7F7 72%
  static const yellow = Color.fromRGBO(255, 204, 0, 1); // #FFCC00
  static const accentPink = Color.fromRGBO(255, 45, 85, 1); // #FF2D55
  static const gray0 = Color.fromRGBO(250, 250, 247, 1); // #FAFAF7
  static const gray5 = Color.fromRGBO(243, 243, 240, 1); // #F3F3F0
  static const gray10 = Color.fromRGBO(234, 234, 228, 1); // #EAEAE4
  static const gray15 = Color.fromRGBO(225, 225, 214, 1);
  static const gray20 = Color.fromRGBO(215, 215, 207, 1); // #D7D7CF
  static const gray30 = Color.fromRGBO(191, 191, 182, 1); // #BFBFB6
  static const gray40 = Color.fromRGBO(162, 162, 153, 1); // #A2A299
  static const gray50 = Color.fromRGBO(126, 126, 118, 1); // #7E7E76
  static const gray60 = Color.fromRGBO(83, 83, 78, 1); // #53534E
  static const gray70 = Color.fromRGBO(38, 38, 35, 1); // #262623
  static const gray80 = Color.fromRGBO(26, 25, 23, 1); // #1A1917
  static const settingsItem = Color.fromRGBO(243, 243, 248, 1); // #F3F3F8
  static const transparentDark = Color.fromRGBO(
      26, 25, 23, 0.48); // #1A1917 48%
  static const transparentGray = Color.fromRGBO(
      83, 83, 78, 0.48); // #53534E 48%
  static const lockBg = Color.fromRGBO(191, 191, 182, 0.48); // #BFBFB6 48%
  static const transparentBlack = Color.fromRGBO(0, 0, 0, 0.6); // #000000 60%
  static const transparentLight = Color.fromRGBO(
      250, 250, 247, 0.85); // #FAFAF7 85%
  static const toastBg = Color.fromRGBO(26, 25, 23, 0.8);

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


class AppColorsV2 {
  // Will replace AppColors once all re-design is done.
  // these colors are present in the color map.
  static const purple = Color.fromRGBO(127, 88, 236, 1);
  static const purpleActive = Color.fromRGBO(104, 62, 222, 1);
  static const purpleDisabled = Color.fromRGBO(98, 70, 174, 1);
  static const purpleShadow = Color.fromRGBO(117, 82, 217, 1);
  static const green = Color.fromRGBO(43, 204, 119, 1);
  static const darkBg = Color.fromRGBO(29, 28, 31, 1);
  static const blockBg = Color.fromRGBO(45, 43, 49, 1);
  static const item = Color.fromRGBO(73, 70, 82, 1);
  static const red = Color.fromRGBO(252, 92, 101, 1);
  static const text = Color.fromRGBO(237, 238, 240, 1);
  static const textDisabled = Color.fromRGBO(175, 175, 177, 1);

  // these colors are not present in the color map, but found in design.
  static const itemFocus = Color.fromRGBO(171, 165, 189, 1);
  static const darkShadow = Color.fromRGBO(0, 0, 0, 0.55);
  static const textShadow1 = Color.fromRGBO(50, 50, 71, 0.06);
  static const textShadow2 = Color.fromRGBO(50, 50, 71, 0.06);
  static const purpleInputBg = Color.fromRGBO(52, 31, 109, 1);
  static const lightPurpleShadow = Color.fromRGBO(127, 88, 236, 1);
  static const decorationGray = Color.fromRGBO(60, 58, 67, 1);
  static const navBg = Color.fromRGBO(60, 58, 67, 0.72);
  static const modalOverlay = Color.fromRGBO(0, 0, 0, 0.7);
  static const appbarBorder = Color.fromRGBO(255, 255, 255, 0.2);

  // these are for text in different parts of the design.
  static const textPrimary = Color.fromRGBO(255, 255, 255, 1);  // white
  static const textSecondary = Color.fromRGBO(215, 215, 207, 1);  // gray 20%
  static const textPrimaryMute = Color.fromRGBO(191, 191, 182, 1);  // gray 30%
  static const textSecondaryMute = Color.fromRGBO(162, 162, 153, 1);  // gray 40%

  // and these are for inputs.
  static const inputText = Color.fromRGBO(250, 250, 247, 1);  // gray 0%
  static const inputPlaceholder = Color.fromRGBO(126, 126, 118, 1);  // gray 50%
  static const searchText = Color.fromRGBO(234, 234, 228, 1);  // gray 10%
  static const searchPlaceholder = Color.fromRGBO(191, 191, 182, 1);  // gray 30%
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
  static const screenSubTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
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
      letterSpacing: -0.41, color: AppColors.bluePurple);
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
  static const toastText = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 17/13,
      letterSpacing: -0.24, color: AppColors.gray0);
  static const settingsItem = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.gray80);
  static const settingsSelected = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 15, height: 20/15,
      letterSpacing: -0.24, color: AppColors.megaPurple);
  static const settingsTitle = TextStyle(fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.normal, fontSize: 13, height: 18/13,
      letterSpacing: -0.08, color: AppColors.gray60);
}


class AppFontsV2 {
  // large (common) text
  static const textPrimary = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.normal,
    height: 24/18, color: AppColorsV2.textPrimary,);
  static const textPrimaryMute = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimaryMute,);
  static const textSecondary = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.normal,
    height: 24/18, color: AppColorsV2.textSecondary,);
  static const textSecondaryMute = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.normal,
    height: 24/18, color: AppColorsV2.textSecondaryMute,);

  // medium-sized text
  static const midText = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 24/15, color: AppColorsV2.textSecondary,);

  // small text
  static const smallText = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 15.6/13, color: AppColorsV2.textPrimary,);
  static const smallTextMute = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 15.6/13, color: AppColorsV2.textSecondaryMute,);

  // logo
  static const largeLogo = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w900, fontSize: 50,
    height: 50/50, color: AppColorsV2.textPrimary,);
  static const smallLogo = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w900, fontSize: 28,
    height: 28/28, color: AppColorsV2.textPrimary,);

  // input-related
  static const input = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.normal, fontSize: 18,
    height: 24/18, color: AppColorsV2.inputText,);
  static const inputPlaceholder = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.normal, fontSize: 18,
    height: 24/18, color: AppColorsV2.inputPlaceholder,);
  static const inputAlert = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 15.6/13, color: AppColorsV2.red,);
  static const search = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 24/15, color: AppColorsV2.searchText,);
  static const searchPlaceholder = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 24/15, color: AppColorsV2.searchPlaceholder,);

  // buttons
  static const largeButton = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.w700,
    height: 24/18, color: AppColorsV2.text,);
  static const largeButtonDisabled = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.w700,
    height: 24/18, color: AppColorsV2.textDisabled,);
  static const smallButton = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w700, fontSize: 16,
    height: 24/16, color: AppColorsV2.textPrimary,);

  // items and blocks
  static const blockTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w800, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimary,);
  static const itemTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w500, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimary,);
  static const itemTextPrimary = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 18/15, color: AppColorsV2.textPrimary,);
  static const itemTextSecondary = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 18/15, color: AppColorsV2.textSecondary,);

  // other titles
  static const settingsTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 24/15, color: AppColorsV2.textSecondaryMute,);
  static const screenTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w700, fontSize: 20,
    height: 28/20, color: AppColorsV2.textPrimary,);
  static const introTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w900, fontSize: 32,
    height: 40/32, color: AppColorsV2.textPrimary,);

  // modals
  static const modalTitle = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w700, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimary,);
  static const modalText = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 15.6/13, color: AppColorsV2.textSecondary,);
  static const modalButtonPrimary = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w500, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimary,);
  static const modalButtonSecondary = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 18,
    height: 24/18, color: AppColorsV2.textPrimary,);

  // channel program
  static const program = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 16,
    height: 20/16, color: AppColorsV2.textSecondary,);
  static const programLive = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w500, fontSize: 16,
    height: 20/16, color: AppColorsV2.textSecondary,);
  static const programMute = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 16,
    height: 20/16, color: AppColorsV2.textSecondaryMute,);

  // other texts
  static const tabSwitch = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 18/13, color: AppColorsV2.textPrimaryMute,);
  static const tabSwitchActive = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w700, fontSize: 13,
    height: 18/13, color: AppColorsV2.purple,);
  static const tabbar = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w500, fontSize: 11,
    height: 13/11, color: AppColorsV2.textSecondary,);
  static const link = TextStyle(fontFamily: 'Lato',
    fontSize: 18, fontWeight: FontWeight.w400,
    height: 24/18, color: AppColorsV2.purple,);
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
  static final user = SvgPicture.asset('assets/icons/bb_profile.svg', width: 28, height: 28,);
  static final userActive = SvgPicture.asset('assets/icons/bb_profile_active.svg', width: 28, height: 28,);
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
  static final favRemove = SvgPicture.asset('assets/icons/fav_remove.svg', width: 28, height: 28,);
  static final showProgram = SvgPicture.asset('assets/icons/program_open.svg', width: 44, height: 44,);
  static final hideProgram = SvgPicture.asset('assets/icons/program_close.svg', width: 44, height: 44,);
  static final pinkDot = Image.asset('assets/icons/pink_dot.png', width: 8, height: 8,);
  static final plus = SvgPicture.asset('assets/icons/plus.svg', width: 36, height: 36,);
  static final checkHex = SvgPicture.asset('assets/icons/check_hex.svg', width: 31, height: 36,);
  static final check = SvgPicture.asset('assets/icons/check.svg', width: 28, height: 28,);
  static final list = SvgPicture.asset('assets/icons/list.svg', width: 28, height: 28,);
  static final listLight = SvgPicture.asset('assets/icons/list_light.svg', width: 28, height: 28,);
  static final cancel = SvgPicture.asset('assets/icons/cancel.svg', width: 16, height: 16,);
  static final cog = SvgPicture.asset('assets/icons/cog-8_contour.svg', width: 28, height: 28);
  static final trashRed = SvgPicture.asset('assets/icons/trash-red.svg', width: 28, height: 28);
  static final notificationsBell = SvgPicture.asset('assets/icons/notifications-bell.svg', width: 28, height: 28);
}

class AppIconsV2 {
  static final arrowLeft = SvgPicture.asset('assets/icons/new/arrow_left.svg', width: 28, height: 28,);
  static final bell = SvgPicture.asset('assets/icons/new/bell.svg', width: 28, height: 28,);
  static final burger = SvgPicture.asset('assets/icons/new/burger.svg', width: 28, height: 28,);
  static final check = SvgPicture.asset('assets/icons/new/check.svg', width: 24, height: 24,);
  static final chevronLeft = SvgPicture.asset('assets/icons/new/chevron_left.svg', width: 28, height: 28,);
  static final chromecast = SvgPicture.asset('assets/icons/new/chromecast.svg', width: 24, height: 24,);
  static final clear = SvgPicture.asset('assets/icons/new/clear.svg', width: 16, height: 16,);
  static final clearLarge = SvgPicture.asset('assets/icons/new/clear_large.svg', width: 24, height: 24,);
  static final close = SvgPicture.asset('assets/icons/new/close.svg', width: 18, height: 18,);
  static final cog = SvgPicture.asset('assets/icons/new/cog.svg', width: 28, height: 28,);
  static final cogSmall = SvgPicture.asset('assets/icons/new/cog_small.svg', width: 24, height: 24,);
  static final delete = SvgPicture.asset('assets/icons/new/delete.svg', width: 24, height: 24,);
  static final fullScreen = SvgPicture.asset('assets/icons/new/full_screen.svg', width: 24, height: 24,);
  static final heart = SvgPicture.asset('assets/icons/new/heart.svg', width: 28, height: 28,);
  static final heartActive = SvgPicture.asset('assets/icons/new/heart_active.svg', width: 28, height: 28,);
  static final home = SvgPicture.asset('assets/icons/new/home.svg', width: 28, height: 28,);
  static final homeActive = SvgPicture.asset('assets/icons/new/home_active.svg', width: 28, height: 28,);
  static final largeAccount = SvgPicture.asset('assets/icons/new/large_account.svg', width: 56, height: 56,);
  static final largeFavorites = SvgPicture.asset('assets/icons/new/large_favorites.svg', width: 56, height: 56,);
  static final largeLock = SvgPicture.asset('assets/icons/new/large_lock.svg', width: 56, height: 56,);
  static final largeLogo = SvgPicture.asset('assets/icons/new/large_logo.svg', width: 106, height: 122,);
  static final largeRadio = SvgPicture.asset('assets/icons/new/large_radio.svg', width: 56, height: 56,);
  static final largeTv = SvgPicture.asset('assets/icons/new/large_tv.svg', width: 56, height: 56,);
  static final loader = SvgPicture.asset('assets/icons/new/loader.svg', width: 28, height: 28,);
  static final lock = SvgPicture.asset('assets/icons/new/lock.svg', width: 20, height: 20,);
  static final lockLarge = SvgPicture.asset('assets/icons/new/lock_large.svg', width: 48, height: 48,);
  static final next = SvgPicture.asset('assets/icons/new/next.svg', width: 24, height: 24,);
  static final pause = SvgPicture.asset('assets/icons/new/pause.svg', width: 48, height: 48,);
  static final play = SvgPicture.asset('assets/icons/new/play.svg', width: 48, height: 48,);
  static final prev = SvgPicture.asset('assets/icons/new/prev.svg', width: 24, height: 24,);
  static final search = SvgPicture.asset('assets/icons/new/search.svg', width: 28, height: 28,);
  static final searchInput = SvgPicture.asset('assets/icons/new/search_input.svg', width: 16, height: 16,);
  static final smallLogo = SvgPicture.asset('assets/icons/new/small_logo.svg', width: 30, height: 34.5,);
  static final smallScreen = SvgPicture.asset('assets/icons/new/small_screen.svg', width: 24, height: 24,);
  static final star = SvgPicture.asset('assets/icons/new/star.svg', width: 28, height: 28,);
  static final starActive = SvgPicture.asset('assets/icons/new/star_active.svg', width: 28, height: 28,);
  static final user = SvgPicture.asset('assets/icons/new/user.svg', width: 28, height: 28,);
  static final userActive = SvgPicture.asset('assets/icons/new/user_active.svg', width: 28, height: 28,);
  static final more = SvgPicture.asset('assets/icons/new/more.svg', width: 20, height: 20,);
  static final live = SizedBox(
    width: 8,
    height: 8,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: ColoredBox(
        color: AppColorsV2.red,
      ),
    ),
  );
}


class AppImages {
  static final logo = Image.asset('assets/images/logo.png', width: 246, height: 267, filterQuality: FilterQuality.high,);
  static final logoTop = Image.asset('assets/images/logo_top.png', width: 146, height: 48, filterQuality: FilterQuality.medium,);
  static final lock = Image.asset('assets/images/lock.png', width: 140, height: 148, filterQuality: FilterQuality.high,);
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
