import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/settings.dart';
import '../utils/pref_helper.dart';
import '../widgets/app_searchbar.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/category_carousel.dart';
import '../widgets/channel_list.dart';
import '../widgets/square_list.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/bottom_navbar.dart';


class TVChannelsScreen extends StatefulWidget {
  @override
  _TVChannelsScreenState createState() => _TVChannelsScreenState();
}


class _TVChannelsScreenState extends State<TVChannelsScreen> {
  List<Channel> _channels = [];
  String _searchText;
  Genre _category;
  ChannelListType _listType;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadListType();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.tvChannels();
    setState(() { _channels = channels; });
  }

  Future<void> _loadListType() async {
    ChannelListType listType = await PrefHelper.loadString(
      PrefKeys.listType,
      restore: ChannelListType.getByName,
      defaultValue: ChannelListType.defaultChoice,
    );
    setState(() { _listType = listType; });
  }

  void _setSearchText(String text) {
    setState(() { _searchText = text.isEmpty ? null : text; });
  }

  void _setCategory(Genre genre) {
    setState(() { _category = genre.id == 0 ? null : genre; });
  }

  bool Function(Channel channel) get _filter {
    if(_searchText == null && _category == null) return null;
    return (Channel channel) {
      bool result = true;
      if(_searchText != null) result = result && channel.name
          .toLowerCase().contains(_searchText.toLowerCase());
      if(_category != null) result = result && channel.genreId == _category.id;
      return result;
    };
  }

  void _setListType(ChannelListType type) {
    setState(() { _listType = type; });
    PrefHelper.saveString(PrefKeys.listType, type);
  }

  Widget get _appBar {
    return AppSearchBar(
      title: locale(context).tvChannelsTitle,
      onSearchSubmit: _setSearchText,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 6, left: 1),
          child: AppIconButton(
            onPressed: _openDrawer,
            icon: AppIcons.burger,
            padding: EdgeInsets.all(5),
          ),
        ),
      ],
    );
  }

  Widget get _categoryBlock {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale(context).categories,
            style: AppFonts.blockTitle,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: CategoryCarousel(
            categories: Genre.genres,
            onItemTap: _setCategory,
            activeId: _category == null ? 0 : _category.id,
          ),
        ),
      ],
    );
  }

  Widget get _channelList => Padding(
    padding: EdgeInsets.only(top: 24),
    child: ChannelList(
      channels: _channels,
      filter: _filter,
    ),
  );

  Widget get _squareList => SquareList(
    channels: _channels,
    filter: _filter,
  );

  Widget get _body {
    return _listType == ChannelListType.list ? Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _categoryBlock,
          Expanded(
            child: _channelList,
          ),
        ],
      ),
    ) : _squareList;
  }

  Widget get _bottomBar => BottomNavBar();

  void _openDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Widget get _drawer {
    AppLocalizations l = locale(context);
    return Drawer(
      child: ColoredBox(
        color: AppColors.decorativeGray,
        child: SingleChildScrollView (
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SettingsBlock<Genre>(
                title: l.settingsCategories,
                items: Genre.genres,
                getText: (item) => item.name,
                onTap: _setCategory,
                isActive: (item) => _category == null
                    ? item.id == 0 : item == _category
              ),
              SettingsBlock<ChannelListType>(
                title: l.channelListType,
                items: ChannelListType.choices,
                getText: (item) => item.name,
                onTap: _setListType,
                isActive: (item) => item == _listType,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.whiteBg,
      extendBody: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
      endDrawer: _drawer,
    );
  }
}
