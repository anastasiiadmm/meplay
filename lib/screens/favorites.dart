import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/tab_switch.dart';
import '../widgets/favorites_list.dart';
import '../widgets/radio_favorites_list.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/settings.dart';
import '../models.dart';
import '../theme.dart';


class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}


class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Channel> _tv = [];
  List<Channel> _radio = [];
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
      _loadTv();
      _loadRadio();
    }
  }

  Future<void> _getUser() async {
    _user = await User.getUser();
    if (_user == null) {
      _user = await Navigator.of(context).pushNamed<User>('/login');
    }
  }

  Future<void> _loadTv() async {
    List<Channel> channels = await Channel.tvChannels();
    List<int> favIds = await _user.tvFavorites();
    List<Channel> favChannels = channels.where((channel) {
      return favIds.contains(channel.id);
    }).toList();
    setState(() { _tv = favChannels; });
  }

  Future<void> _loadRadio() async {
    List<Channel> allChannels = await Channel.radioChannels();
    List<int> favIds = await _user.radioFavorites();
    List<Channel> favChannels = allChannels.where((channel) {
      return favIds.contains(channel.id);
    }).toList();
    setState(() { _radio = favChannels; });
  }

  Widget get _appBar {
    return AppToolBar(
      title: locale(context).favoritesTitle,
    );
  }

  Future<void> _deleteTv(Channel channel) async {
    await _user.removeFavorite(channel);
    setState(() { _tv.remove(channel); });
  }

  Future<void> _deleteRadio(Channel channel) async {
    await _user.removeFavorite(channel);
    setState(() { _radio.remove(channel); });
  }

  Widget get _body => Padding(
    padding: EdgeInsets.only(top: 20),
    child: TabSwitch(
      leftLabel: locale(context).favoritesTv,
      rightLabel: locale(context).favoritesRadio,
      leftTab: FavoritesList(
        channels: _tv,
        onDelete: _deleteTv,
      ),
      rightTab: RadioFavoritesList(
        channels: _radio,
        onDelete: _deleteRadio,
      ),
    ),
  );

  Widget get _bottomBar => BottomNavBar(showIndex: NavItems.favorites,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      extendBody: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
