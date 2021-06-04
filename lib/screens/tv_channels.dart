import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/settings.dart';
import '../widgets/app_searchbar.dart';
import '../widgets/category_carousel.dart';
import '../widgets/channel_list.dart';
import '../widgets/bottom_navbar.dart';


class TVChannelsScreen extends StatefulWidget {
  @override
  _TVChannelsScreenState createState() => _TVChannelsScreenState();
}


class _TVChannelsScreenState extends State<TVChannelsScreen> {
  List<Channel> _channels = [];
  String _searchText;
  Genre _category;

  @override
  void initState() {
    super.initState();
    // TODO:
    // _loadListType();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    List<Channel> channels = await Channel.tvChannels();
    setState(() { _channels = channels; });
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
    return AppSearchBar(
      title: locale(context).tvChannelsTitle,
      onSearchSubmit: _setSearchText,
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

  Widget get _categoryBlock {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale(context).categories,
            style: AppFontsV2.blockTitle,
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

  Widget get _body => Padding(
    padding: EdgeInsets.only(top: 20),
    child: Column(
      children: [
        _categoryBlock,
        Expanded(
          child: _channelList,
        ),
      ],
    ),
  );

  Widget get _bottomBar => BottomNavBar();

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
