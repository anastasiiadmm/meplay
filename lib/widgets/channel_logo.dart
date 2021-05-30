import 'dart:io';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class ChannelLogo extends StatelessWidget {
  final Channel channel;
  static const double size = 82;

  ChannelLogo({Key key, @required this.channel}): super(key: key);

  Widget get _logo {
    return FutureBuilder<File>(
      future: channel.logo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Image.file(snapshot.data)
            : Padding(
          padding: EdgeInsets.all(5),
          child: AppIconsV2.logoPlaceholder,
        );
      },
    );
  }

  Widget get _lock {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        color: AppColorsV2.overlay,
      ),
      child: SizedBox(
        width: 28,
        height: 28,
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
        borderRadius: BorderRadius.circular(8),
        color: AppColorsV2.channelBg,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
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
