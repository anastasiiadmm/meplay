import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/fcm_helper.dart';
import '../utils/local_notification_helper.dart';
import '../utils/tz_helper.dart';
import '../utils/deeplink_helper.dart';
import '../theme.dart';
import '../models.dart';
import '../router.dart';
import '../utils/settings.dart';
import 'splash.dart';


class Circle extends StatelessWidget {
  final Color color;
  final double diameter;
  final Widget child;

  Circle({
    Key key,
    this.color: Colors.transparent,
    this.diameter: 1,
    this.child,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: child,
      ),
    );
  }
}


class Dot extends Circle {
  Dot({
    Key key,
    Color color: Colors.transparent,
    double diameter: 1,
  }): super(
    key: key,
    color: color,
    diameter: diameter,
  );
}


class BannerCarousel extends StatefulWidget {
  final List<AppBanner> banners;
  final void Function(int id) onTap;

  BannerCarousel({
    Key key,
    @required this.banners,
    this.onTap,
  }): assert(banners.length > 0),
        super(key: key);
  
  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _activeId = 0;
  CarouselController _controller = CarouselController();

  void _switchTo(int id) {
    _controller.animateToPage(id);
  }

  void _pageChanged(int id, CarouselPageChangedReason reason) {
    setState(() {
      _activeId = id;
    });
  }

  Widget _dot(id) {
    Widget dot;
    if (id == _activeId) {
      dot = Dot(
        color: AppColorsV2.purple,
        diameter: 8,
      );
    } else {
      dot = GestureDetector(
        onTap: () => _switchTo(id),
        child: Dot(
          color: AppColorsV2.decorativeGray,
          diameter: 8,
        ),
      );
    }
    if (id > 0) {
      dot = Padding(
        padding: EdgeInsets.only(left: 8),
        child: dot,
      );
    }
    return dot;
  }

  Widget get _dots {
    List<Widget> items = [];
    for(int id = 0; id < widget.banners.length; id++) {
      items.add(_dot(id));
    }
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items,
      ),
    );
  }

  Widget _banner(int id) {
    AppBanner banner = widget.banners[id];
    Widget content = FutureBuilder<File>(
      future: banner.image,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Image.file(snapshot.data)
            : AppImages.bannerStub;
      },
    );
    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: () => widget.onTap(id),
        child: content,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: content,
      ),
    );
  }

  Widget get _bannerCarousel {
    List<Widget> items = [];
    for(int id = 0; id < widget.banners.length; id++) {
      items.add(_banner(id));
    }
    return CarouselSlider(
      carouselController: _controller,
      items: items,
      options: CarouselOptions(
        viewportFraction: 1.0,
        height: 180,
        autoPlay: true,
        onPageChanged: _pageChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bannerCarousel,
          _dots,
        ]
    );
  }
}


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

  List<AppBanner> _banners = [
    AppBanner(targetUrl: Routes.tv),
    AppBanner(targetUrl: Routes.login),
    AppBanner(targetUrl: Routes.radio),
    AppBanner(targetUrl: Routes.tv),
    AppBanner(targetUrl: Routes.tv),
  ];

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
    Navigator.of(context).pushNamed(Routes.favorites);
  }

  void _openFavorites() {
    Navigator.of(context).pushNamed(Routes.profile);
  }

  void _onBannerTap(int id) {
    String url = _banners[id].targetUrl;
    if(Routes.allowed(url) && url != Routes.home) {
      Navigator.of(context).pushNamed(url);
    }
  }

  // Widget get _popularBlock {
  //
  // }
  //
  // Widget get _recentBlock {
  //
  // }

  Widget get _bannerBlock {
    return BannerCarousel(banners: _banners, onTap: _onBannerTap,);
  }

  Widget _mainButton(Image image, {
    @required String text,
    @required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: AppColorsV2.decorativeGray,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: image,
              ),
              Text(text, style: AppFontsV2.itemTitle,)
            ],
          ),
        ),
      ),
    );
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
                      child:_mainButton(
                        AppImages.tv,
                        text: locale(context).homeTv,
                        onTap: _watchTV,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _mainButton(
                      AppImages.radio,
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
                  child: _mainButton(
                    AppImages.favorites,
                    text: locale(context).homeFavorites,
                    onTap: _openFavorites,
                  ),
                ),
              ),
              Expanded(
                child: _mainButton(
                  AppImages.account,
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

  Widget get _body {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _mainButtonBlock,
          _bannerBlock,
          // _recentBlock,
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
