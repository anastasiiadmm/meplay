import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
  static const decorativeGray = Color.fromRGBO(60, 58, 67, 1);
  static const navBg = Color.fromRGBO(60, 58, 67, 0.72);
  static const overlay = Color.fromRGBO(0, 0, 0, 0.7);
  static const appbarBorder = Color.fromRGBO(255, 255, 255, 0.2);
  static const iconBg = Color.fromRGBO(255, 255, 255, 1);  // white
  static const channelBg = Color.fromRGBO(255, 255, 255, 1);
  static const modalBorder = Color.fromRGBO(29, 27, 29, 1);
  static const iconColor = Color.fromRGBO(234, 234, 228, 1);  // gray 10%;

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

  // various colors.
  static const white = Color.fromRGBO(255, 255, 255, 1);
  static const black = Color.fromRGBO(0, 0, 0, 1); // #000000
  static const transparent = Color.fromRGBO(0, 0, 0, 0); // #000000
  static const transparentWhite = Color.fromRGBO(255, 255, 255, 0.6);
  static const transparentBlack = Color.fromRGBO(0, 0, 0, 0.6);

  static const gradientTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [transparentBlack, AppColorsV2.transparent],
  );
  static const gradientBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [transparentBlack, AppColorsV2.transparent],
  );
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
  static const inputError = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 13,
    height: 15.6/13, color: AppColorsV2.red,);
  static const search = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 15,
    height: 20/15, color: AppColorsV2.searchText,);
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
  static const notificationCount = TextStyle(fontFamily: 'Lato',
    fontSize: 10, fontWeight: FontWeight.w700,
    height: 12/10, color: AppColorsV2.textPrimary,);
  static const placeholderText = TextStyle(fontFamily: 'Lato',
    fontSize: 14, fontWeight: FontWeight.w400,
    height: 20/14, color: AppColorsV2.item,
  );
  static const placeholderTextLarge = TextStyle(fontFamily: 'Lato',
    fontSize: 16, fontWeight: FontWeight.w400,
    height: 24/16, color: AppColorsV2.item,
  );

  // player
  static const fullscreenProgram = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 16,
    height: 24/16, color: AppColorsV2.textSecondary,);
  static const playerLive = TextStyle(fontFamily: 'Lato',
    fontWeight: FontWeight.w400, fontSize: 10,
    height: 10/10, color: AppColorsV2.textPrimary,);
}


class AppIconsV2 {
  static final arrowLeft = SvgPicture.asset('assets/icons/new/arrow_left.svg', width: 28, height: 28,);
  static final bell = SvgPicture.asset('assets/icons/new/bell.svg', width: 28, height: 28,);
  static final burger = SvgPicture.asset('assets/icons/new/burger.svg', width: 28, height: 28,);
  static final check = SvgPicture.asset('assets/icons/new/check.svg', width: 24, height: 24,);
  static final chevronLeft = SvgPicture.asset('assets/icons/new/chevron_left.svg', width: 28, height: 28,);
  static final chromecast = SvgPicture.asset('assets/icons/new/chromecast.svg', width: 24, height: 24,);
  static final clear = SvgPicture.asset('assets/icons/new/clear.svg', width: 16, height: 16,);
  static final clearBig = SvgPicture.asset('assets/icons/new/clear_big.svg', width: 24, height: 24,);
  static final close = SvgPicture.asset('assets/icons/new/close.svg', width: 18, height: 18,);
  static final cog = SvgPicture.asset('assets/icons/new/cog.svg', width: 28, height: 28,);
  static final cogSmall = SvgPicture.asset('assets/icons/new/cog_small.svg', width: 24, height: 24,);
  static final delete = SvgPicture.asset('assets/icons/new/delete.svg', width: 24, height: 24,);
  static final fullScreen = SvgPicture.asset('assets/icons/new/full_screen.svg', width: 24, height: 24,);
  static final heart = SvgPicture.asset('assets/icons/new/heart.svg', width: 28, height: 28,);
  static final heartActive = SvgPicture.asset('assets/icons/new/heart_active.svg', width: 28, height: 28,);
  static final home = SvgPicture.asset('assets/icons/new/home.svg', width: 28, height: 28,);
  static final homeActive = SvgPicture.asset('assets/icons/new/home_active.svg', width: 28, height: 28,);
  static final loader = SvgPicture.asset('assets/icons/new/loader.svg', width: 28, height: 28,);
  static final lock = SvgPicture.asset('assets/icons/new/lock.svg', width: 20, height: 20,);
  static final lockBig = SvgPicture.asset('assets/icons/new/lock_big.svg', width: 48, height: 48,);
  static final next = SvgPicture.asset('assets/icons/new/next.svg', width: 24, height: 24,);
  static final play = SvgPicture.asset('assets/icons/new/play.svg', width: 48, height: 48,);
  static final pause = SvgPicture.asset('assets/icons/new/pause.svg', width: 48, height: 48,);
  static final prev = SvgPicture.asset('assets/icons/new/prev.svg', width: 24, height: 24,);
  static final search = SvgPicture.asset('assets/icons/new/search.svg', width: 28, height: 28,);
  static final searchInput = SvgPicture.asset('assets/icons/new/search_input.svg', width: 16, height: 16,);
  static final smallScreen = SvgPicture.asset('assets/icons/new/small_screen.svg', width: 24, height: 24,);
  static final star = SvgPicture.asset('assets/icons/new/star.svg', width: 28, height: 28,);
  static final starActive = SvgPicture.asset('assets/icons/new/star_active.svg', width: 28, height: 28,);
  static final user = SvgPicture.asset('assets/icons/new/user.svg', width: 28, height: 28,);
  static final userActive = SvgPicture.asset('assets/icons/new/user_active.svg', width: 28, height: 28,);
  static final more = SvgPicture.asset('assets/icons/new/more.svg', width: 20, height: 20,);
  static final logoPlaceholder = SvgPicture.asset('assets/icons/new/logo_placeholder.svg', width: 106, height: 122,);
}


class AppImages {
  static final logo = Image.asset('assets/images/logo.png', width: 246, height: 267, filterQuality: FilterQuality.high,);
  static final logoTop = Image.asset('assets/images/logo_top.png', width: 146, height: 48, filterQuality: FilterQuality.high,);
  static final account = Image.asset('assets/images/account.png', width: 56, height: 56, filterQuality: FilterQuality.high,);
  static final tv = Image.asset('assets/images/tv.png', width: 56, height: 56, filterQuality: FilterQuality.high,);
  static final radio = Image.asset('assets/images/radio.png', width: 56, height: 56, filterQuality: FilterQuality.high,);
  static final favorites = Image.asset('assets/images/favorites.png', width: 56, height: 56, filterQuality: FilterQuality.high,);
  static final largeTv = Image.asset('assets/images/largeTv.png', width: 110, height: 110, filterQuality: FilterQuality.high,);
  static final largeBell = Image.asset('assets/images/largeBell.png', width: 110, height: 110, filterQuality: FilterQuality.high,);
  static final lock = Image.asset('assets/images/lock.png', width: 140, height: 148, filterQuality: FilterQuality.high,);

  // used for testing and when banner image is not available
  static final bannerStub = Image.asset('assets/images/banner_stub.png', width: 343, height: 180, filterQuality: FilterQuality.high);
}
