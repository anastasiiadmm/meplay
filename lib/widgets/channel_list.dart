import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';


class ChannelList extends StatelessWidget {
  final List<Channel> channels;

  ChannelList({Key key, @required this.channels}): super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return ListView(
      children: channels.map<Widget>((channel) {
        Widget result = ChannelTile(channel: channel);
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
