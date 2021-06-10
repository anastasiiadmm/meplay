import 'dart:math';
import 'package:flutter/material.dart';
import 'package:me_play/theme.dart';


class RotationLoader extends StatefulWidget {
  @override
  _RotationLoaderState createState() => _RotationLoaderState();
}

class _RotationLoaderState extends State<RotationLoader>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _angle;
  final double start = 0;
  final double end = 2 * pi;
  final double step = pi / 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _angle = Tween<double>(begin: start, end: end).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _toStep(double start, double end, double step, double value) {
    assert(value >= start && value <= end);
    double times = (value - start) / step;
    double result = start + step * times.round();
    if(result > end) result = end;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Transform.rotate(
          angle: _toStep(start, end, step, _angle.value),
          child: child,
        );
      },
      child: AppIcons.loader,
    );
  }
}
