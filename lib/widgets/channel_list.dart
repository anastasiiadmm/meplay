import 'package:flutter/material.dart';
import 'package:me_play/theme.dart';
import '../models.dart';
import 'channel_tile.dart';
import 'base_channels.dart';


class ChannelList extends BaseChannels {
  final void Function(Channel channel) delete;

  ChannelList({
    Key key,
    @required List<Channel> channels,
    bool Function(Channel channel) filter,
    this.delete,
  }): super(
    key: key,
    channels: channels,
    filter: filter,
  );

  bool get _hasActions {
    return delete != null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: channelsToDisplay.map<Widget>((channel) {
        return Padding(
          padding: EdgeInsets.only(bottom: _hasActions ? 12 : 8),
          child: ChannelTile(
            channel: channel,
            onTap: () => openChannel(context, channel),
            actions: _hasActions ? <ChannelAction>[
              if(delete != null) ChannelAction(
                action: () => delete(channel),
                icon: AppIconsV2.delete,
              ),
            ] : null,
          ),
        );
      }).toList(),
    );
  }
}
