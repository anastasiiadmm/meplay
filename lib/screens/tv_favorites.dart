import 'dart:async';
import 'package:flutter/material.dart';
import 'package:me_play/widgets/search_bar.dart';
import '../widgets/bottom_navbar.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/settings.dart';
import '../widgets/channel_list.dart';


class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}


class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Channel> _channels = [];
  bool Function(Channel channel) _filter;
  User _user;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _getUser();
    if (_user == null) Navigator.of(context).pop();
    else {
      // TODO:
      //  _loadListType();
      _loadChannels();
    }
  }

  Future<void> _getUser() async {
    _user = await User.getUser();
    if (_user == null) {
      _user = await Navigator.of(context).pushNamed<User>('/login');
    }
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.tvChannels();
    List<int> favIds = await _user.tvFavorites();
    List<Channel> favChannels = channels.where((channel) {
      return favIds.contains(channel.id);
    }).toList();
    favChannels.sort((ch1, ch2) => ch1.number.compareTo(ch2.number));
    setState(() {
      _channels = favChannels;  // copy
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
      title: locale(context).favoritesTitle,
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

  Future<void> _delete(Channel channel) async {
    User user = await User.getUser();
    await user.removeFavorite(channel);
    setState(() {
      _channels.remove(channel);
    });
  }

  Widget get _body => Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
    child: ChannelList(
      channels: _channels,
      filter: _filter,
      delete: (channel) => _delete(channel),
    ),
  );

  Widget get _bottomBar => BottomNavBar(showIndex: NavItems.favorites,);

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
