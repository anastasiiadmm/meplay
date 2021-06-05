import 'package:flutter/material.dart';


class Circle extends StatelessWidget {
  final Color color;
  final double radius;
  final Widget child;
  final EdgeInsetsGeometry padding;

  Circle({
    Key key,
    this.color: Colors.transparent,
    this.radius: 0,
    this.child,
    this.padding: EdgeInsets.zero,
  }): assert(radius >= 0),
        super(key: key);

  Circle.dot({
    Key key,
    this.color: Colors.transparent,
    this.radius: 0,
  }): assert(radius >= 0),
        child = null,
        padding = EdgeInsets.zero,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
