import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/circle.dart';
import '../theme.dart';
import '../utils/settings.dart';


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}


class _IntroScreenState extends State<IntroScreen> {
  CarouselController _controller;
  int _activeId;
  static const _pageCount = 2;

  void initState() {
    super.initState();
    _controller = CarouselController();
    _activeId = 0;
  }

  void _skip() {
    Navigator.of(context).pop();
  }

  void _next() {
    if(_activeId < _pageCount - 1) {
      _controller.animateToPage(_activeId + 1);
      setState(() {
        _activeId++;
      });
    } else {
      _skip();
    }
  }

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
      dot = Circle.dot(
        color: AppColorsV2.purple,
        radius: 4,
      );
    } else {
      dot = GestureDetector(
        onTap: () => _switchTo(id),
        child: Circle.dot(
          color: AppColorsV2.decorativeGray,
          radius: 4,
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
    for(int id = 0; id < _pageCount; id++) {
      items.add(_dot(id));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }

  Widget _page({String title, String text, String asset}) {
    return GestureDetector(
      onTap: _next,
      child: SizedBox(
        height: double.infinity,  // TODO:
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(asset),
            Text(
              title,
              style: AppFontsV2.introTitle,
              textAlign: TextAlign.center,
            ),
            if(text != null) Text(
              text,
              style: AppFontsV2.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _carousel {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          carouselController: _controller,
          // TODO:
          items: [
            _page(
              title: '1',
              text: "wtf",
              asset: "/some/path",
            ),
            _page(
              title: '2',
              text: "fts",
              asset: "/other/path",
            ),
          ],
          options: CarouselOptions(
            viewportFraction: 1,
            // height: ?,
            // aspectRatio: ?
            onPageChanged: _pageChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: _dots,
        )
      ],
    );

    // _dots ?
  }

  Widget get _skipButton {
    return GestureDetector(
      onTap: _skip,
      child: Text(
        locale(context).introSkip,
        style: AppFontsV2.textSecondaryMute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 75),
            child: _carousel,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 75),
          child: _skipButton,
        ),
      ],
    );
  }
}
