import 'package:flutter/material.dart';


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
