import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_tile.dart';


class ChannelList extends StatelessWidget {
  final List<Channel> channels;
  final bool Function(Channel channel) filter;

  ChannelList({
    Key key,
    @required this.channels,
    this.filter,
  }): super(key: key);

  List<Channel> get _filterChannels {
    if(filter == null) return channels;
    return channels.where(filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return ListView(
      children: _filterChannels.map<Widget>((channel) {
        Widget tile = Padding(
          padding: id == 0
              ? EdgeInsets.symmetric(vertical: 8)
              : EdgeInsets.only(bottom: 8),
          child: ChannelTile(
            channel: channel,
            onTap: () => channel.open(context),
          ),
        );
        id++;
        return tile;
      }).toList(),
    );
  }
}
