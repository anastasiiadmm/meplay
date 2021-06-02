import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';
import 'base_channels.dart';


class ChannelColumn extends BaseChannels {
  ChannelColumn({
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
    int id = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: channelsToDisplay.map<Widget>((channel) {
        Widget result = ChannelTile(
          channel: channel,
          onTap: () => openChannel(context, channel),
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
