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
import '../widgets/channel_column.dart';
import '../inherited/news_count_notifier.dart';
import '../inherited/recent_notifier.dart';
import '../inherited/popular_notifier.dart';


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
    Channel.loadRecent();
    Channel.loadPopular();
    await TZHelper.init();
    _deeplinkHelper = DeeplinkHelper.instance;
    await _deeplinkHelper.checkInitialLink();
    await News.load();
    await LocalNotificationHelper.init();
    FCMHelper helper = await FCMHelper.initialize();
    await helper.checkInitialMessage();
    _asyncInitDone = true;
    _doneLoading();
  }

  List<AppBanner> _banners;
  Future<List<AppBanner>> _loadBanners() async {
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
    return Column(
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
    );
  }

  Widget get _bannerBlock {
    return FutureBlock<List<AppBanner>>(
      future: _loadBanners(),
      builder: (BuildContext context, banners) => BannerCarousel(
        banners: banners,
        onTap: _onBannerTap,
      ),
      size: Size.fromHeight(BannerCarousel.totalHeight),
    );
  }

  Widget _emptyBlockText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: AppFontsV2.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _recentBlock {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          child: RecentNotifier(
            notifier: Channel.recentNotifier,
            child: Builder(
              builder: (BuildContext context) {
                List<Channel> recent = RecentNotifier.of(context)
                    .recentChannels;
                return (recent != null && recent.length > 0)
                    ? ChannelCarousel(channels: recent)
                    : _emptyBlockText(locale(context).homeRecentEmpty);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget get _popularBlock {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale(context).homePopular,
            style: AppFontsV2.blockTitle,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: PopularNotifier(
            notifier: Channel.popularNotifier,
            child: Builder(
              builder: (BuildContext context) {
                List<Channel> channels = PopularNotifier.of(context)
                    .popularChannels;
                return (channels != null && channels.length > 0)
                    ? ChannelColumn(channels: channels)
                    : _emptyBlockText(locale(context).homePopularEmpty);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget get _body {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: _mainButtonBlock,
          ),
          // баннер имеет 20px паддинг вокруг себя для показа тени
          // поэтому здесь вокруг баннера нет паддинга,
          // но его нужно учитывать при подсчёте паддинга
          // в соседних блоках.
          if(_showBanner) _bannerBlock,
          Padding(
            padding: _showBanner
                ? EdgeInsets.symmetric(vertical: 10)
                : EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: _recentBlock,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
            child: _popularBlock,
          ),
        ]
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed(Routes.notifications);
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
          onTap: _openNotifications,
          child: UnreadNewsNotifier(
            notifier: News.unreadCountNotifier,
            child: Builder(
              builder: (BuildContext context) {
                int newsCount = UnreadNewsNotifier.of(context).count;
                return Stack(
                  children: [
                    Center(
                      child: AppIconsV2.bell,
                    ),
                    if(newsCount > 0) Positioned(
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
                              newsCount.toString(),
                              style: AppFontsV2.notificationCount,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
