import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';
import 'base_channels.dart';


class ChannelList extends BaseChannels {
  ChannelList({
    Key key,
    @required List<Channel> channels,
    bool Function(Channel channel) filter,
  }): super(
    key: key,
    channels: channels,
    filter: filter,
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: channelsToDisplay.map<Widget>((channel) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: ChannelTile(
            channel: channel,
            onOpen: openChannel,
          ),
        );
      }).toList(),
    );
  }
}
