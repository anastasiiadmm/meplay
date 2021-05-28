import 'package:flutter/material.dart';
import '../models.dart';
import 'channel_logo.dart';


class ChannelCarousel extends StatelessWidget {
  final List<Channel> channels;
  static const double height = ChannelLogo.size;

  ChannelCarousel({
    Key key,
    @required this.channels,
  }): assert(channels.length > 0),
        super(key: key);

  void _openChannel(BuildContext context, Channel channel) {
    Navigator.of(context).pushNamed('/tv/${channel.id}');
  }

  Widget _itemBuilder(BuildContext context, int id) {
    Channel channel = channels[id];
    return Padding(
      padding: id == 0
          ? EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => _openChannel(context, channel),
        child: ChannelLogo(channel: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        itemBuilder: _itemBuilder,
      ),
    );
  }
}
