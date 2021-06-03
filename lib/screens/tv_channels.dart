import 'dart:async';
import 'package:flutter/material.dart';
import 'package:me_play/widgets/search_bar.dart';
import '../widgets/bottom_navbar.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/settings.dart';
import '../widgets/channel_list.dart';


class TVChannelsScreen extends StatefulWidget {
  @override
  _TVChannelsScreenState createState() => _TVChannelsScreenState();
}


class _TVChannelsScreenState extends State<TVChannelsScreen> {
  List<Channel> _channels = [];
  bool Function(Channel channel) _filter;

  @override
  void initState() {
    super.initState();
    // TODO:
    // _loadListType();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.tvChannels();
    channels.sort((ch1, ch2) => ch1.number.compareTo(ch2.number));
    setState(() {
      _channels = channels;  // copy
    });
  }

  // TODO:
  // Future<void> _loadListType() async {
  //   ChannelListType listType = await PrefHelper.loadString(
  //     PrefKeys.listType,
  //     restore: ChannelListType.getByName,
  //     defaultValue: ChannelListType.defaultType,
  //   );
  //   setState(() { _listType = listType; });
  // }

  void _setFilter(String text) {
    setState(() {
      _filter = text.isEmpty ? null : (channel) => channel.name
          .toLowerCase()
          .contains(text.toLowerCase());
    });
  }

  // TODO:
  // void _selectListType() {
  //   selectorModal(
  //     title: Text('Вид списка каналов:', textAlign: TextAlign.center,),
  //     context: context,
  //     choices: ChannelListType.choices,
  //     onSelect: (ChannelListType selected) {
  //       setState(() { _listType = selected; });
  //       PrefHelper.saveString(PrefKeys.listType, selected);
  //     },
  //   );
  // }

  Widget get _appBar {
    return SearchBar(
      title: locale(context).tvChannelsTitle,
      onSearchSubmit: _setFilter,
      actions: [
        // TODO:
        // IconButton(
        //   onPressed: _selectListType,
        //   icon: AppIconsV2.burger,
        //   constraints: BoxConstraints(),
        // ),
      ],
    );
  }

  Widget get _body => Padding(
    padding: EdgeInsets.only(top: 16),
    child: ChannelList(
      channels: _channels,
      filter: _filter,
    ),
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
