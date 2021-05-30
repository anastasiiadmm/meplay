import 'dart:math';
import 'package:flutter/material.dart';
import 'package:me_play/theme.dart';


class RotaLoader extends StatefulWidget {
  @override
  _RotaLoaderState createState() => _RotaLoaderState();
}

class _RotaLoaderState extends State<RotaLoader>
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
      child: AppIconsV2.loader,
    );
  }
}


class FutureBlock<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget loader;
  final Size size;

  FutureBlock({
    Key key,
    @required this.future,
    @required this.builder,
    this.size,
    Widget loader,
  }): this.loader = loader ?? RotaLoader(),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result = Center(
      child: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? loader
              : builder(context, snapshot.data);
        },
      )
    );
    if(size != null) {
      result = SizedBox.fromSize(
        child: result,
        size: size,
      );
    }
    return result;
  }
}
