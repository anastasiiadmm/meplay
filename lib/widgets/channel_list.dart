import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';
import 'channels_base.dart';


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
    int id = 0;
    return ListView(
      children: channelsToDisplay.map<Widget>((channel) {
        Widget result = ChannelTile(
          channel: channel,
          onOpen: openChannel,
        );
        if(id > 0) result = Padding(
          padding: EdgeInsets.only(top: 8),
          child: result,
        );
        id++;
        return result;
      }).toList(),
    );
  }
}
