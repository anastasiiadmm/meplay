import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class ChannelListScreen extends StatefulWidget {
  final List<Channel> channels;

  ChannelListScreen({Key key, this.channels}): super();

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}


class _ChannelListScreenState extends State<ChannelListScreen> {
  @override
  Widget build(BuildContext context) {

    return Container(color: Colors.green);
  }
}
