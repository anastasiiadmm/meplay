import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/pref_helper.dart';
import '../widgets/channel_list_old.dart';
import 'player.dart';


class RadioChannelsScreen extends StatefulWidget {
  @override
  _RadioChannelsScreenState createState() => _RadioChannelsScreenState();
}


class _RadioChannelsScreenState extends State<RadioChannelsScreen> {
  List<Channel> _initialChannels = [];
  List<Channel> _channels = [];
  bool _search = false;
  final _searchController = TextEditingController();
  ChannelListType _listType = ChannelListType.defaultType;

  @override
  void initState() {
    super.initState();
    _loadListType();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    List<Channel> allChannels = await Channel.radioChannels();
    allChannels.sort((ch1, ch2) => ch1.number.compareTo(ch2.number));
    setState(() {
      _initialChannels = allChannels;
      _channels = _initialChannels.toList();  // copy
    });
  }

  Future<void> _loadListType() async {
    ChannelListType listType = await PrefHelper.loadString(
      PrefKeys.listType,
      restore: ChannelListType.getByName,
      defaultValue: ChannelListType.defaultType,
    );
    setState(() { _listType = listType; });
  }

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  Widget get _bottomBar => BottomNavBar();

  // TODO: add star button into channel list items
  // Future<void> _addFavorite(Channel channel) async {
  //   User user = await User.getUser();
  //   if(user != null) await user.addFavorite(channel);
  // }
  //
  // Future<void> _removeFavorite(Channel channel) async {
  //   User user = await User.getUser();
  //   if(user != null) await user.removeFavorite(channel);
  // }
  //
  // Future<void> _toggleFavorite(Channel channel) async {
  //   User user = await User.getUser();
  //   if (user != null) {
  //     String message;
  //     if (await user.hasFavorite(channel)) {
  //       await _addFavorite(channel);
  //       message = 'Канал "${channel.name}" удалён из избранного';
  //     } else {
  //       await _removeFavorite(channel);
  //       message = 'Канал "${channel.name}" добавлен в избранное';
  //     }
  //     grayToast(context, message);
  //   }
  // }

  Future<void> _openChannel(Channel channel) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PlayerScreen(
          channelId: channel.id,
          channelType: ChannelType.radio,
          getNextChannel: _nextChannel,
          getPrevChannel: _prevChannel,
        ),
        settings: RouteSettings(name: '/radio/${channel.id}'),
      ),
    );
  }

  Channel _nextChannel(Channel channel) {
    int index = _initialChannels.indexOf(channel);
    if(index < _initialChannels.length - 1) {
      return _initialChannels[index + 1];
    }
    return _initialChannels[0];
  }

  Channel _prevChannel(Channel channel) {
    int index = _initialChannels.indexOf(channel);
    if(index > 0) {
      return _initialChannels[index - 1];
    }
    return _initialChannels[_initialChannels.length - 1];
  }

  Widget get _body => ChannelList(
    channels: _channels,
    openChannel: _openChannel,
    listType: _listType,
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
    setState(() { _channels = _initialChannels; });
  }

  void _toggleSearch() {
    if(_search) _hideSearch();
    else _openSearch();
  }

  void _filterChannels(String value) {
    List<Channel> channels = _initialChannels;
    if (value.isNotEmpty) {
      channels = channels.where((channel) {
        return channel.name.toLowerCase().contains(
          value.toLowerCase(),
        );
      }).toList();
    }
    setState(() { _channels = channels; });
  }

  void _searchSubmit() {
    FocusScope.of(context).unfocus();
    _filterChannels(_searchController.text);
  }

  void _selectListType() {
    selectorModal(
      title: Text('Вид списка каналов:', textAlign: TextAlign.center,),
      context: context,
      choices: ChannelListType.choices,
      onSelect: (ChannelListType selected) {
        setState(() { _listType = selected; });
        PrefHelper.saveString(PrefKeys.listType, selected);
      },
    );
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: _search
          ? _searchInput()
          : Text('Радио', style: AppFonts.screenTitle),
      centerTitle: !_search,
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: AppIcons.search,
        ),
        IconButton(
          onPressed: _selectListType,
          icon: AppIcons.listLight,
        ),
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
              onFieldSubmitted: _filterChannels,
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
    if (_channels.length != _initialChannels.length) {
      _clearSearch();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _willPop() async {
    if (_channels.length != _initialChannels.length) {
      _clearSearch();
      return false;
    }
    return true;
  }

  Color get _bodyBg => _listType == ChannelListType.hexagonal
      ? AppColors.megaPurple
      : AppColors.gray0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        backgroundColor: _bodyBg,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: _appBar,
        body: _body,
        bottomNavigationBar: _bottomBar,
      ),
    );
  }
}
