import 'package:flutter/material.dart';
import '../models.dart';
import 'favorites_tile.dart';


class FavoritesList extends StatelessWidget {
  final List<Channel> channels;
  final void Function(Channel channel) onDelete;

  FavoritesList({
    Key key,
    @required this.channels,
    this.onDelete,
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
          child: FavoritesTile(
            channel: channel,
            onTap: () => channel.open(context),
            onDelete: () => onDelete(channel),
          ),
        );
      },
    );
  }
}
