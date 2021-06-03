import 'package:flutter/material.dart';
import '../models.dart';
import 'favorites_tile.dart';
import 'base_channels.dart';


class FavoritesList extends BaseChannels {
  final void Function(Channel channel) onDelete;

  FavoritesList({
    Key key,
    @required List<Channel> channels,
    bool Function(Channel channel) filter,
    this.onDelete,
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
          padding: EdgeInsets.only(bottom: 12),
          child: FavoritesTile(
            channel: channel,
            onTap: () => openChannel(context, channel),
            onDelete: () => onDelete(channel),
          ),
        );
      }).toList(),
    );
  }
}
