import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/pref_helper.dart';
import '../utils/settings.dart';
import '../widgets/channel_list.dart';


class TVChannelsScreen extends StatefulWidget {
  @override
  _TVChannelsScreenState createState() => _TVChannelsScreenState();
}


class _TVChannelsScreenState extends State<TVChannelsScreen> {
  List<Channel> _channels = [];
  bool Function(Channel channel) _filter;
  bool _search = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO:
    // _loadListType();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  Widget get _bottomBar => BottomNavBar();

  Widget get _body => Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: ChannelList(
      channels: _channels,
      filter: _filter,
    ),
  );

  void _openSearch() {
    setState(() { _search = true; });
  }

  void _hideSearch() {
    setState(() { _search = false; });
  }

  void _clearSearch() {
    _searchController.value = TextEditingValue.empty;
    FocusScope.of(context).unfocus();
    setState(() { _filter = null; });
  }

  void _toggleSearch() {
    if(_search) _hideSearch();
    else _openSearch();
  }

  void _setFilter(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _filter = (channel) => channel.name
            .toLowerCase()
            .contains(text.toLowerCase());
      });
    }
  }

  void _searchSubmit() {
    FocusScope.of(context).unfocus();
    _setFilter(_searchController.text);
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
    return AppBar(
      backgroundColor: AppColorsV2.item,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: _search
          ? _searchInput()
          : Text(locale(context).tvChannelsTitle, style: AppFonts.screenTitle),
      centerTitle: !_search,
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: AppIcons.search,
        ),
        // TODO:
        // IconButton(
        //   onPressed: _selectListType,
        //   icon: AppIcons.listLight,
        // ),
      ],
    );
  }

  Widget _searchInput() {
    return Container(
      height: 36,
      child: Stack(
        children: [
          Focus(
            onFocusChange: (hasFocus) {
              if(hasFocus) _restoreSystemOverlays();
            },
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: AppFonts.searchInputText,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              controller: _searchController,
              onFieldSubmitted: _setFilter,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                hintText: 'Введите название канала',
                hintStyle: AppFonts.searchInputHint,
                fillColor: AppColors.transparentDark,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10)
                ),
                errorMaxLines: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: AppIcons.searchInput,
              onPressed: _searchSubmit,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              constraints: BoxConstraints(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: AppIcons.cancel,
              onPressed: _clearSearch,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _back() {
    if (_filter != null) {
      _clearSearch();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _willPop() async {
    if (_filter != null) {
      _clearSearch();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: AppColorsV2.darkBg,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: _appBar,
        body: _body,
        bottomNavigationBar: _bottomBar,
      ),
    );
  }
}
