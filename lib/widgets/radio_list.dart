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
    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (BuildContext context, int id) {
        Channel channel = channels[id];
        return Padding(
          padding: id == 0
              ? EdgeInsets.symmetric(vertical: 12)
              : EdgeInsets.only(bottom: 12),
          child: RadioTile(
            channel: channel,
            onTap: () => channel.open(context),
          ),
        );
      },
    );
  }
}
