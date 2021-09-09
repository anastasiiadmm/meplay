import 'package:flutter/material.dart';

import '../models.dart';
import 'channel_logo.dart';

class ChannelCarousel extends StatelessWidget {
  final List<Channel> channels;

  ChannelCarousel({
    Key key,
    @required this.channels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LogoSize.large.size,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        itemBuilder: (BuildContext context, int id) {
          Channel channel = channels[id];
          return Padding(
            padding: id == 0
                ? EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => channel.open(context),
              child: ChannelLogo(
                channel: channel,
                textPlaceholder: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
