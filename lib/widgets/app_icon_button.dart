import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


// wraps IconButton and provides default padding to zero,
// removes default size constraints, and tries
// to determine icon size from the icon itself.
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final double iconSize;
  final void Function() onPressed;
  final EdgeInsetsGeometry padding;
  static const defaultSize = 24.0;

  AppIconButton({
    Key key,
    this.icon,
    this.iconSize,
    this.onPressed,
    this.padding: EdgeInsets.zero,
  }): super(key: key);

  double get _size {
    if(iconSize != null) return iconSize;
    if(icon is SvgPicture) {
      SvgPicture pic = icon as SvgPicture;
      if(pic.width == null) return pic.height ?? defaultSize;
      if(pic.height == null) return pic.width;
      return max<double>(pic.width, pic.height);
    }
    if(icon is Image) {
      Image img = icon as Image;
      if(img.width == null) return img.height ?? defaultSize;
      if(img.height == null) return img.width;
      return max<double>(img.width, img.height);
    }
    if(icon is Icon) {
      Icon ic = icon as Icon;
      return ic.size ?? defaultSize;
    }
    return defaultSize;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      iconSize: _size,
      onPressed: onPressed,
      padding: padding,
      constraints: BoxConstraints(),
    );
  }
}
