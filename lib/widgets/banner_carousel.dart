import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models.dart';
import '../theme.dart';
import 'circle.dart';


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
  final double bannerHeight = 180;
  final double topShadowPadding = 20;
  final double bottomShadowPadding = 48;
  final double dotsHeight = 28;

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
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
      padding: EdgeInsets.fromLTRB(16, topShadowPadding, 16, bottomShadowPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.darkShadow,
              offset: Offset(0, 10),
              blurRadius: 35,
            ),
          ],
        ),
        child: FittedBox(
          child: content,
          fit: BoxFit.contain,
        ),
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
        viewportFraction: 1,
        height: bannerHeight + topShadowPadding + bottomShadowPadding,
        autoPlay: true,
        onPageChanged: _pageChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _bannerCarousel,
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomShadowPadding - dotsHeight,
          child: _dots,
        ),
      ],
    );
  }
}
