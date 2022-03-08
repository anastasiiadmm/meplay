import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:me_play/utils/pref_helper.dart';
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
  bool _showBanner = true;  // while banner is not real - hide it.
  bool _firstLaunch = false;

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
    await Channel.fullReload();
    await _loadFirstLaunch();
    await TZHelper.init();
    _deeplinkHelper = DeeplinkHelper.instance;
    await _deeplinkHelper.checkInitialLink();
    await News.load();
    await LocalNotificationHelper.init();
    FCMHelper helper = await FCMHelper.initialize();
    if(helper != null) await helper.checkInitialMessage();
    _asyncInitDone = true;
    _doneLoading();
  }

  final GlobalKey<ScaffoldState> _scaffoldDrawerKey = GlobalKey<ScaffoldState>();

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

  Future<void> _loadFirstLaunch() async {
    String firstLaunch = await PrefHelper.loadString(PrefKeys.firstLaunch);
    if(firstLaunch == null) {
      _firstLaunch = true;
      await PrefHelper.saveString(PrefKeys.firstLaunch, 'true');
    }
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

  Future<void> _showIntro() async {
    await Navigator.of(context).pushNamed('/intro');
    _watchTV();
  }

  void _splashHide() {
    if(_firstLaunch) _showIntro();
    else if(!_deeplinkHelper.navigated) _watchTV();
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

  void _openDrawer() {
    _scaffoldDrawerKey.currentState.openDrawer();
  }

  Widget get _mainButtonBlock {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 15, bottom: 10, left: 15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 5),
                    child: LargeImageButton(
                      image: AppImages.tv_null,
                      text: locale(context).homeTv,
                      onTap: _watchTV,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: LargeImageButton(
                      image: AppImages.radio_null,
                      text: locale(context).homeRadio,
                      onTap: _listenRadio,
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 15, bottom: 10, left: 15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 5),
                    child: LargeImageButton(
                      image: AppImages.favorite_null,
                      text: locale(context).homeFavorites,
                      onTap: _openFavorites,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: LargeImageButton(
                      image: AppImages.account_null,
                      text: locale(context).homeProfile,
                      onTap: _openProfile,
                    ),
                  )
                ),
              ],
            ),
          ),
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
        style: AppFonts.textSecondary,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get _recentBlock {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale(context).homeRecent,
            style: AppFonts.blockTitles,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale(context).homePopular,
            style: AppFonts.blockTitles,
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
                return (channels == null && channels.length > 0)
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
            if(_showBanner) _bannerBlock,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: _mainButtonBlock,
            ),
            // баннер имеет 20px паддинг вокруг себя для показа тени
            // поэтому здесь вокруг баннера нет паддинга,
            // но его нужно учитывать при подсчёте паддинга
            // в соседних блоках.
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
        color: AppColors.whiteBg,
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
                      child: AppIcons.notifications_bell,
                    ),
                    if(newsCount > 0) Positioned(
                      top: 8,
                      right: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.white,
                        ),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: Center(
                            child: Text(
                              newsCount.toString(),
                              style: AppFonts.notificationCount,
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
      preferredSize: Size(double.infinity, 55),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 20, 5,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AppImages.logoMainTop,
            _notificationsBtn,
          ],
        ),
      ),
    );
  }

  Widget get _drawer {
    return Drawer(
      child: ColoredBox(
        color: AppColors.lightBg,
        child: SingleChildScrollView (
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

            ],
          ),
        ),
      ),
    );
  }

  Widget get _appBarMain {
    return AppBar(
      backgroundColor: AppColors.lightBg,
      leading: IconButton(
        onPressed: _openDrawer,
        icon: AppIcons.burger_menu,
      ),
      actions: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 85, 10,),
            // child: AppImages.logoMainTop
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 25, 10,),
            child: _notificationsBtn
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? SplashScreen(
      onShow: _splashShow,
      onHide: _splashHide,
      isVisible: _isSplashShowing,
    ) : Scaffold(
      key: _scaffoldDrawerKey,
      backgroundColor: AppColors.lightBg,
      drawer: _drawer,
      appBar: _appBarMain,
      body: _body,
      bottomNavigationBar: null,
    );
  }
}
