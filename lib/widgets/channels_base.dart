import 'package:flutter/material.dart';
import '../screens/player.dart';
import '../models.dart';


abstract class BaseChannels extends StatelessWidget {
  final List<Channel> channels;
  final bool Function(Channel channel) filter;

  BaseChannels({
    Key key,
    @required this.channels,
    this.filter,
  }): super(key: key);

  Future<void> openChannel(BuildContext context, Channel channel) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PlayerScreen(
          channelId: channel.id,
          channelType: channel.type,
          getNextChannel: _next,
          getPrevChannel: _prev,
        ),
        settings: RouteSettings(name: '/${channel.typeString}/${channel.id}'),
      ),
    );
  }

  Channel _next(Channel channel) {
    int index = channels.indexOf(channel);
    if(index < channels.length - 1) {
      return channels[index + 1];
    }
    return channels[0];
  }

  Channel _prev(Channel channel) {
    int index = channels.indexOf(channel);
    if(index > 0) {
      return channels[index - 1];
    }
    return channels[channels.length - 1];
  }

  List<Channel> get channelsToDisplay {
    if(filter == null) return channels;
    return channels.where(filter);
  }
}
