import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models.dart';
import 'channel_logo.dart';


class ChannelCarousel extends StatelessWidget {
  final List<Channel> channels;

  ChannelCarousel({
    Key key,
    @required this.channels,
  }): assert(channels.length > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: channels.map((channel) => Padding(
        padding: EdgeInsets.only(left: 16),
        child: ChannelLogo(
          channel: channel,
        ),
      )).toList(),
      options: CarouselOptions(
        autoPlay: false,
        viewportFraction: 0.27,
      ),
    );
  }
}
