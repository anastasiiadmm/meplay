import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/radio_list.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/settings.dart';


class RadioChannelsScreen extends StatefulWidget {
  @override
  _RadioChannelsScreenState createState() => _RadioChannelsScreenState();
}


class _RadioChannelsScreenState extends State<RadioChannelsScreen> {
  List<Channel> _channels = [];

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.radioChannels();
    setState(() { _channels = channels; });
  }

  Widget get _appBar {
    return AppToolBar(
      title: locale(context).radioChannelsTitle,
    );
  }

  Widget get _body => RadioList(
    channels: _channels,
  );

  Widget get _bottomBar => BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
