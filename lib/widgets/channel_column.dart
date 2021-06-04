import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';


class ChannelColumn extends StatelessWidget {
  final  List<Channel> channels;

  ChannelColumn({
    Key key,
    @required this.channels,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: channels.map<Widget>((channel) {
        Widget result = ChannelTile(
          channel: channel,
          onTap: () => channel.open(context),
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
