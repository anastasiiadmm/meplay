import 'dart:io';

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
        color: AppColors.decorativeGray,
        radius: 4,
      );
    } else {
      dot = InkWell(
        onTap: () => _switchTo(id),
        child: Circle.dot(
          color: AppColors.grayDisabled,
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
    return InkWell(
      onTap: _next,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16,),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 225,
              child: Center(
                child: Image.asset(asset),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: Text(
                title,
                style: AppFonts.introTitle,
                textAlign: TextAlign.center,
              ),
            ),
            if(text != null) Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                text,
                style: AppFonts.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _carousel {
    AppLocalizations l = locale(context);
    return CarouselSlider(
      carouselController: _controller,
      items: [
        _page(
          title: l.introTvTitle,
          text: l.introTvText,
          asset: 'assets/images/intro_null_1.png',
        ),
        _page(
          title: l.introRemindTitle,
          text: l.introRemindText,
          asset: 'assets/images/intro_null_2.png',
        ),
      ],
      options: CarouselOptions(
        viewportFraction: 1,
        aspectRatio: 0.5,
        onPageChanged: _pageChanged,
      ),
    );
  }

  Widget get _skipButton {
    return InkWell(
      onTap: _skip,
      child: Text(
        locale(context).introSkip,
        style: AppFonts.textSecondaryMute,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteBg,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Platform.isIOS ? 20 : 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _carousel,
            ),
            _dots,
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: _skipButton,
            ),
          ],
        ),
      ),
    );
  }
}
