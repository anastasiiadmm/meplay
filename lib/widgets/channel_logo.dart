import 'dart:io';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class ChannelLogo extends StatelessWidget {
  final Channel channel;
  static const double size = 82;

  ChannelLogo({Key key, @required this.channel}): super(key: key);

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
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Center(
            child: FutureBuilder<File>(
              future: channel.logo,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? Image.file(snapshot.data)
                    : AppIconsV2.logoPlaceholder;
              },
            ),
          ),
        ),
      ),
    );
  }
}
