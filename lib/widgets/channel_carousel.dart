import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_logo.dart';
import 'base_channels.dart';


class ChannelCarousel extends BaseChannels {
  ChannelCarousel({
    Key key,
    @required List<Channel> channels,
    bool Function(Channel channel) filter,
  }) : super(
    key: key,
    channels: channels,
    filter: filter,
  );

  @override
  Widget build(BuildContext context) {
    List<Channel> display = channelsToDisplay;
    return SizedBox(
      height: LogoSize.large.size,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channelsToDisplay.length,
        itemBuilder: (BuildContext context, int id) {
          Channel channel = display[id];
          return Padding(
            padding: id == 0
                ? EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => openChannel(context, channel),
              child: ChannelLogo(channel: channel),
            ),
          );
        },
      ),
    );
  }
}
