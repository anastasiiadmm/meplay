import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/favorites_list.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/settings.dart';
import '../models.dart';
import '../theme.dart';


class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}


class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Channel> _channels = [];
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

  Widget get _appBar {
    return AppToolBar(
      title: locale(context).favoritesTitle,
    );
  }

  Future<void> _onDelete(Channel channel) async {
    User user = await User.getUser();
    await user.removeFavorite(channel);
    setState(() {
      _channels.remove(channel);
    });
  }

  Widget get _body => Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
    child: FavoritesList(
      channels: _channels,
      onDelete: _onDelete,
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
