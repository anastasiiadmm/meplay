import 'package:flutter/material.dart';
import '../models.dart';
import 'radio_tile.dart';


class RadioList extends StatelessWidget {
  final List<Channel> channels;

  RadioList({
    Key key,
    @required this.channels,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = 0;
    return ListView(
      children: channels.map<Widget>((channel) {
        Widget tile = Padding(
          padding: id == 0
              ? EdgeInsets.symmetric(vertical: 12)
              : EdgeInsets.only(bottom: 12),
          child: RadioTile(
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
