import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/fcm_helper.dart';
import '../utils/local_notification_helper.dart';
import '../utils/tz_helper.dart';
import '../utils/deeplink_helper.dart';
import '../theme.dart';
import '../models.dart';
import '../router.dart';
import '../utils/settings.dart';
import 'splash.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/large_image_button.dart';
import '../widgets/channel_carousel.dart';
import '../widgets/future_block.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;  // if splash is present on screen
  bool _asyncInitDone = false;
  bool _splashAnimationDone = false;
  bool _isSplashShowing = true;  // if splash animates from hidden to visible or back
  DeeplinkHelper _deeplinkHelper;
  bool _showBanner = false;  // while banner is not real - hide it.

  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    _deeplinkHelper.dispose();
    super.dispose();
  }

  Future<void> _initAsync() async {
    await User.getUser();
    await Future.wait([
      Channel.loadTv(),
      Channel.loadRadio(),
    ]);
    await TZHelper.init();
    _deeplinkHelper = DeeplinkHelper.instance;
    await _deeplinkHelper.checkInitialLink();
    await LocalNotificationHelper.init();
    FCMHelper helper = await FCMHelper.initialize();
    await helper.checkInitialMessage();
    _asyncInitDone = true;
    _doneLoading();
  }

  List<Channel> _recentChannels = [];
  Future<void> _loadRecent() async {
    // TODO: provide through notifier.
    List<Channel> recent = [];

    // stub
    List<Channel> channels = await Channel.tvChannels();
    for(int i = 0; i < 10; i++) { recent.add(channels[i]); }

    setState(() { _recentChannels = recent; });
  }

  List<AppBanner> _banners;
  Future<List<AppBanner>> _loadBanners() async {
    // TODO: load from api.

    // stub
    if(_banners == null) _banners = await Future<List<AppBanner>>.delayed(
      Duration(seconds: 2),
      () => [
        AppBanner(targetUrl: Routes.tv),
        AppBanner(targetUrl: Routes.login),
        AppBanner(targetUrl: Routes.radio),
        AppBanner(targetUrl: Routes.tv),
        AppBanner(targetUrl: Routes.tv),
      ],
    );

    return _banners;
  }

  void _doneLoading() {
    if(_asyncInitDone && _splashAnimationDone) {
      setState(() { _isSplashShowing = false; });
    }
  }

  void _splashShow() {
    _splashAnimationDone = true;
    _doneLoading();
  }

  void _splashHide() {
    if(!_deeplinkHelper.navigated) _watchTV();
    Timer(Duration(milliseconds: 300), () {
      setState(() { _loading = false; });
    });
  }

  void _watchTV() {
    Navigator.of(context).pushNamed(Routes.tv);
  }

  void _listenRadio() {
    Navigator.of(context).pushNamed(Routes.radio);
  }

  void _openProfile() {
    Navigator.of(context).pushNamed(Routes.profile);
  }

  void _openFavorites() {
    Navigator.of(context).pushNamed(Routes.favorites);
  }

  void _onBannerTap(int id) {
    String url = _banners[id].targetUrl;
    if(Routes.allowed(url) && url != Routes.home) {
      Navigator.of(context).pushNamed(url);
    }
  }

  Widget get _mainButtonBlock {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 1),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 1),
                      child: LargeImageButton(
                        image: AppImages.tv,
                        text: locale(context).homeTv,
                        onTap: _watchTV,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LargeImageButton(
                      image: AppImages.radio,
                      text: locale(context).homeRadio,
                      onTap: _listenRadio,
                    ),
                  ),
                ]
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 1),
                  child: LargeImageButton(
                    image: AppImages.favorites,
                    text: locale(context).homeFavorites,
                    onTap: _openFavorites,
                  ),
                ),
              ),
              Expanded(
                child: LargeImageButton(
                  image: AppImages.account,
                  text: locale(context).homeProfile,
                  onTap: _openProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _bannerBlock {
    // баннер имеет 20px паддинг вокруг себя для показа тени
    // поэтому здесь нет паддинга и нужно учитывать его наличие
    // при подсчёте паддинга в других блоках.
    return FutureBlock<List<AppBanner>>(
      future: _loadBanners(),
      builder: (banners) => BannerCarousel(
        banners: banners,
        onTap: _onBannerTap,
      ),
      size: Size.fromHeight(BannerCarousel.totalHeight),
    );
  }

  Widget get _recentBlock {
    return Padding(
      padding: _showBanner
          ? EdgeInsets.symmetric(vertical: 10)
          : EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              locale(context).homeRecent,
              style: AppFontsV2.blockTitle,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: ChannelCarousel(channels: _recentChannels),
          ),
        ],
      ),
    );
  }


  // Widget get _popularBlock {
  //
  // }

  Widget get _body {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _mainButtonBlock,
          if(_showBanner) _bannerBlock,
          if(_recentChannels.length > 0) _recentBlock,
          // _popularBlock,
        ]
      ),
    );
  }

  // Widget get _authNotifierExample {
  //   return AuthNotifier(
  //     child: Builder(
  //       builder: (BuildContext context) {
  //         User user = AuthNotifier.of(context).user;
  //         return user == null ? null : null;
  //       },
  //     ),
  //     notifier: User.userNotifier,
  //   );
  // }

  void _openNotifications() {
    Navigator.of(context).pushNamed(Routes.notifications);
  }

  int get _notificationsCount {
    // TODO: get real count depending on user notifier.
    int count = 99;
    if(count > 99) count = 99;
    return count;
  }

  Widget get _notificationsBtn {
    return SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: AppColorsV2.iconBg,
          type: MaterialType.circle,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            child: Stack(
              children: [
                Center(
                  child: AppIconsV2.bell,
                ),
                if(_notificationsCount > 0) Positioned(
                  top: 8,
                  right: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColorsV2.purple,
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: Text(
                          _notificationsCount.toString(),
                          style: AppFontsV2.notificationCount,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: _openNotifications,
          ),
        ),
      );
  }

  Widget get _appBar {
    return PreferredSize(
      preferredSize: Size(double.infinity, 68),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppImages.logoTop,
            _notificationsBtn,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? SplashScreen(
      onShow: _splashShow,
      onHide: _splashHide,
      isVisible: _isSplashShowing,
    ) : Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: null,
    );
  }
}
