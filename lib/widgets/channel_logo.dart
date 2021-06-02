import 'dart:io';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class LogoSize {
  final double size;
  final double radius;
  final double padding;
  final double lockSize;

  const LogoSize._(this.size, this.radius, this.padding, this.lockSize);

  static const large = LogoSize._(82, 8, 8, 28);
  static const small = LogoSize._(48, 5, 6, 24);
}


class ChannelLogo extends StatelessWidget {
  final Channel channel;
  final LogoSize size;

  ChannelLogo({
    Key key,
    @required this.channel,
    this.size: LogoSize.large,
  }): super(key: key);

  Widget get _logo {
    return FutureBuilder<File>(
      future: channel.logo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Image.file(snapshot.data)
            : Padding(
          padding: EdgeInsets.all(size.padding / 1.5),
          child: AppIconsV2.logoPlaceholder,
        );
      },
    );
  }

  Widget get _lock {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(size.radius),
          bottomLeft: Radius.circular(size.radius),
        ),
        color: AppColorsV2.overlay,
      ),
      child: SizedBox(
        width: size.lockSize,
        height: size.lockSize,
        child: Center(
          child: AppIconsV2.lock,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.radius),
        color: AppColorsV2.channelBg,
      ),
      child: SizedBox(
        width: size.size,
        height: size.size,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(size.padding),
              child: Center(
                child: _logo,
              ),
            ),
            if(channel.locked) Positioned(
              top: 0,
              right: 0,
              child: _lock,
            ),
          ],
        ),
      ),
    );
  }
}
