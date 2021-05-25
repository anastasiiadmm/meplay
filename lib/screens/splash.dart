import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';


class SplashScreen extends StatefulWidget {
  final bool isVisible;
  final void Function() onShow;
  final void Function() onHide;

  SplashScreen({
    Key key,
    this.isVisible: true,
    this.onShow,
    this.onHide,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  double _opacity;
  Duration _animationDuration = const Duration(milliseconds: 1500);
  Duration _waitDuration = const Duration(milliseconds: 2000);

  void initState() {
    super.initState();
    _opacity = widget.isVisible ? 0 : 1;
  }

  void _show() {
    Timer.run(() {
      setState(() { _opacity = 1; });
      if (widget.onShow != null) {
        Timer(_animationDuration + _waitDuration, widget.onShow);
      }
    });
  }

  void _hide() {
    Timer.run(() {
      setState(() { _opacity = 0; });
      if (widget.onHide != null) {
        Timer(_animationDuration, widget.onHide);
      }
    });
  }

  void _toggle() {
    if(widget.isVisible) {
      if(_opacity != 1) _show();
    } else {
      if(_opacity != 0) _hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _toggle();
    return Material (
      color: AppColorsV2.darkBg,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: _animationDuration,
        curve: Curves.linear,
        child: Center(
          child: AppImages.logo,
        ),
      ),
    );
  }
}
