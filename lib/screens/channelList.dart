import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/ellipsis.dart';
import '../utils/pref_helper.dart';
import 'base.dart';
import 'player.dart';


class ListViewType {
  final String name;
  final String value;

  const ListViewType(this.name, this.value);

  String toString() {
    return name;
  }

  static const hexagonal = ListViewType('Шестиугольники', 'hexagonal');
  static const list = ListViewType('Список', 'list');
  static const blocks = ListViewType('Блоки', 'blocks');
  static const choices = [hexagonal, list, blocks];
  static const defaultType = hexagonal;

  static ListViewType getByName(String name) {
    for (ListViewType choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultType;
  }
}


class ChannelListScreen extends StatefulWidget {
  final List<Channel> channels;
  final List<Channel> filtered;
  final String title;
  final int selectedNavId;

  ChannelListScreen({Key key, this.channels, this.filtered,
    this.title, this.selectedNavId}) : super();

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}


class _ChannelListScreenState extends State<ChannelListScreen> {
  HexGridSize _gridSize;
  List<Channel> _initialChannels;
  List<Channel> _channels;
  Iterator _iterator;
  final int _borderRows = 2;
  final int _borderCols = 1;
  bool _search = false;
  final _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilityListenerId;
  final _searchController = TextEditingController();
  ListViewType _listType = ListViewType.defaultType;

  @override
  void initState() {
    super.initState();
    _loadListType();
    _initialChannels = widget.filtered == null
        ? widget.channels
        : widget.filtered;
    _initialChannels.sort(
            (ch1, ch2) => ch1.number.compareTo(ch2.number)
    );
    _channels = _initialChannels;
    _keyboardVisibilityListenerId = _keyboardVisibility.addNewListener(
      onShow: _restoreSystemOverlays,
    );
  }

  @override
  void dispose() {
    _keyboardVisibility.removeListener(_keyboardVisibilityListenerId);
    _keyboardVisibility.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListType() async {
    ListViewType listType = await PrefHelper.loadString(
      PrefKeys.listType,
      restore: ListViewType.getByName,
      defaultValue: ListViewType.defaultType,
    );
    setState(() { _listType = listType; });
  }

  void _restoreSystemOverlays() {
    Timer(Duration(milliseconds: 1001), SystemChrome.restoreSystemUIOverlays);
  }

  void _calcGridSize() {
    int rows = max(sqrt(_channels.length).floor(), 5);
    int cols = max((_channels.length / rows).ceil(), 4);
    _gridSize = HexGridSize(rows + _borderRows * 2, cols + _borderCols * 2 + 1);
  }

  void _navTo(int index) {
    if (index != widget.selectedNavId) Navigator.of(context).pop(index);
  }

  Widget get _bottomBar {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _navTo,
      currentIndex: widget.selectedNavId ?? 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.star,
          activeIcon: AppIcons.starActive,
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user,
          label: 'Профиль',
        ),
      ],
    );
  }

  HexagonWidget _hexTileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    double elevation;
    if(point.row < _borderRows
        || point.row > _gridSize.rows - 1 - _borderRows
        || point.row % 2 == 0 && (
            point.col < _borderCols + 1
            || point.col > _gridSize.cols - 1 - _borderCols
        )
        || point.row % 2 != 0 && (
            point.col < _borderCols
            || point.col > _gridSize.cols - 2 - _borderCols
        )
        || !_iterator.moveNext()) {
      color = AppColors.emptyTile;
      elevation = 0;
    } else {
      color = AppColors.gray5;
      elevation = 2.0;
      Channel channel = _iterator.current;
      List<Widget> children = [
        Container(
          height: 71,
          alignment: Alignment.topCenter,
          child: FutureBuilder(
            future: channel.logo,
            builder: (
              BuildContext context,
              AsyncSnapshot<File> snapshot
            ) => (snapshot.data == null) ? Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: AppIcons.channelPlaceholder,
            ) : Container(
              constraints: BoxConstraints(maxWidth: 93, maxHeight: 71),
              alignment: Alignment.center,
              child: Image.file(snapshot.data),
            ),
          ),
        ),
        Padding (
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            channel.title,
            style: AppFonts.channelName,
            textAlign: TextAlign.center,
          ),
        ),
        Padding (
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: FutureBuilder(
            future: channel.currentProgram,
            builder: (BuildContext context, AsyncSnapshot<Program> snapshot) {
              return Text(
                snapshot.data == null ? '' : shorten(snapshot.data.title, 15),
                style: AppFonts.programName,
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ];
      if (channel.locked) {
        children.add(AppIcons.lockChannel);
      }
      content = GestureDetector(
        onTap: () { _openChannel(channel); },
        onLongPress: () { _addToFavorites(channel); },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      );
    }
    return HexagonWidget.template(
      color: color,
      child: content,
      elevation: elevation,
    );
  }

  Future<void> _openChannel(Channel channel) async {
    int index = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PlayerScreen(
          channel: channel,
          getNextChannel: _nextChannel,
          getPrevChannel: _prevChannel,
        ),
      ),
    );
    if (index != null) _navTo(index);
  }

  Channel _nextChannel(Channel channel) {
    if(channel == widget.channels.last) {
      return widget.channels.first;
    } else {
      return widget.channels.firstWhere(
        (element) => element.number > channel.number
      );
    }
  }

  Channel _prevChannel(Channel channel) {
    if(channel == widget.channels.first) {
      return widget.channels.last;
    } else {
      return widget.channels.lastWhere(
        (element) => element.number < channel.number
      );
    }
  }

  Widget get _hexChannelGrid {
    _iterator = _channels.iterator;
    _calcGridSize();

    return ClipRect(
      child: OverflowBox (
        maxWidth: MediaQuery.of(context).size.width + 508,
        maxHeight: MediaQuery.of(context).size.height + 508,
        child: InteractiveViewer(
          constrained: false,
          // TODO add scaling up to 0.5 and resize paddings on scale.
          minScale: 1,
          child: HexagonOffsetGrid.oddPointy(
            columns: _gridSize.cols,
            rows: _gridSize.rows,
            color: AppColors.transparent,
            hexagonPadding: 8,
            hexagonBorderRadius: 15,
            hexagonWidth: 174,
            buildHexagon: _hexTileBuilder,
          ),
        ),
      ),
    );
  }

  _addToFavorites(Channel channel) {
    // TODO;
  }

  Widget _listChannelTile(Channel channel, int id) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      onTap: () => _openChannel(channel),
      onLongPress: () => _addToFavorites(channel),
      leading: FutureBuilder(
        future: channel.logo,
        builder: (
          BuildContext context,
          AsyncSnapshot<File> snapshot
        ) => Container(
          constraints: BoxConstraints(maxWidth: 60, maxHeight: 40),
          alignment: Alignment.center,
          child: (snapshot.data == null)
              ? AppIcons.channelPlaceholder
              : Image.file(snapshot.data),
        ),
      ),
      title: Text(
        channel.title,
        style: AppFonts.channelName,
      ),
      subtitle: FutureBuilder(
        future: channel.currentProgram,
        builder: (BuildContext context, AsyncSnapshot<Program> snapshot) {
          return Text(
            snapshot.data == null ? '' : snapshot.data.title,
            style: AppFonts.programName,
            maxLines: 1,
          );
        },
      ),
      // Hide right now
      // trailing: IconButton(
      //   icon: AppIcons.list,
      //   onPressed: () => null,
      // ),
    );
  }

  Widget get _channelList {
    return ListView.separated(
      itemBuilder: (BuildContext context, int id) {
        Channel channel = _channels[id];
        return _listChannelTile(channel, id);
      },
      separatorBuilder: (BuildContext context, int id) {
        return Divider(height: 0,);
      },
      itemCount: _channels.length,
    );
  }

  Widget _blockChannelTile(Channel channel, int oddity) {
    EdgeInsetsGeometry margin;
    if (oddity < 1) {
      margin = EdgeInsets.only(right: 2.5);
    } else if (oddity > 1) {
      margin = null;
    } else {
      margin = EdgeInsets.only(left: 2.5);
    }
    return GestureDetector(
      onTap: () { _openChannel(channel); },
      onLongPress: () { _addToFavorites(channel); },
      child: Container(
        margin: margin,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darkPurple),
        ),
        child: Column(
          children: [
            FutureBuilder(
              future: channel.logo,
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                return Container(
                  height: 124,
                  width: 180,
                  alignment: Alignment.center,
                  child: (snapshot.data == null)
                      ? AppIcons.channelPlaceholder
                      : Image.file(snapshot.data,),
                );
              },
            ),
            Text(
              channel.title,
              style: AppFonts.channelName,
              textAlign: TextAlign.center,
            ),
            FutureBuilder(
              future: channel.currentProgram,
              builder: (BuildContext context, AsyncSnapshot<Program> snapshot) {
                return Text(
                  snapshot.data == null ? '' : snapshot.data.title,
                  style: AppFonts.programName,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget get _channelBlockList {
    return ListView.builder(
      itemBuilder: (BuildContext context, int id) {
        int oddity = id % 3;
        if (oddity < 1) {
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5,
                id > _channels.length - 3 ? 5 : 0),
            child: IntrinsicHeight (
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _blockChannelTile(_channels[id], oddity)
                  ),
                  Expanded(
                    child: id < _channels.length - 1
                      ? _blockChannelTile(_channels[id + 1], oddity + 1)
                      : Container(
                        margin: EdgeInsets.only(left: 2.5),
                      )
                  ),
                ],
              ),
            ),
          );
        } else if (oddity > 1) {
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5,
                id == _channels.length - 1 ? 5 : 0),
            child: _blockChannelTile(_channels[id], oddity),
          );
        } else {
          // empty widget which takes no space and never displayed.
          return const SizedBox();
        }
      },
      itemCount: _channels.length,
    );
  }
  
  Widget get _body {
    switch (_listType) {
      case ListViewType.hexagonal:
        return _hexChannelGrid;
      case ListViewType.list:
        return _channelList;
      case ListViewType.blocks:
        return _channelBlockList;
      default:
        return _hexChannelGrid;
    }
  }

  void _openSearch() {
    setState(() {
      _search = true;
    });
  }

  void _hideSearch() {
    setState(() {
      _search = false;
    });
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
      channels = channels.where(
        (channel) => channel.name.toLowerCase().contains(value.toLowerCase())
      ).toList();
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
      choices: ListViewType.choices,
      onSelect: (ListViewType selected) {
        setState(() {
          _listType = selected;
        });
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
          : Text(widget.title, style: AppFonts.screenTitle),
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
          TextFormField(
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
              errorMaxLines: 1
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
              icon: Icon(
                Icons.cancel,
                color: AppColors.white,
                size: 16,
              ),
              onPressed: _clearSearch,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _back() {
    if (_search) {
      _hideSearch();
    } else if (_channels.length != widget.channels.length) {
      _clearSearch();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _willPop() async {
    if (_search) {
      _hideSearch();
      return false;
    } else if (_channels.length != widget.channels.length) {
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
        backgroundColor: _listType == ListViewType.hexagonal
            ? AppColors.megaPurple
            : AppColors.gray0,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: _appBar,
        body: _body,
        bottomNavigationBar: _bottomBar,
      ),
    );
  }
}
