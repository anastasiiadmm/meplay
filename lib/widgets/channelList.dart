import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/ellipsis.dart';


class ChannelListType {
  final String name;
  final String value;

  const ChannelListType(this.name, this.value);

  String toString() => name;

  static const hexagonal = ChannelListType('Шестиугольники', 'hexagonal');
  static const list = ChannelListType('Список', 'list');
  static const blocks = ChannelListType('Блоки', 'blocks');
  static const choices = [hexagonal, list, blocks];
  static const defaultType = hexagonal;

  static ChannelListType getByName(String name) {
    for (ChannelListType choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultType;
  }
}


class ChannelList extends StatefulWidget {
  final List<Channel> channels;
  final void Function(Channel) onChannelTap;
  final ChannelListType listType;

  ChannelList({Key key, @required this.channels,
    this.listType: ChannelListType.defaultType,
    @required this.onChannelTap})
      : assert(listType != null),
        assert(channels != null),
        super();

  @override
  _ChannelListState createState() => _ChannelListState();
}


class _ChannelListState extends State<ChannelList> {
  HexGridSize _gridSize;

  // TODO: refactor
  Iterator _iterator;

  int _borderRows = 2;
  int _borderCols = 1;

  @override
  void initState() {
    super.initState();
  }

  void _calcGridSize() {
    int rows = max(sqrt(widget.channels.length).floor(), 5);
    int cols = max((widget.channels.length / rows).ceil(), 4);
    _gridSize = HexGridSize(rows + _borderRows * 2, cols + _borderCols * 2 + 1);
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
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              return (snapshot.data == null) ? Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: AppIcons.channelPlaceholder,
              ) : Container(
                constraints: BoxConstraints(maxWidth: 93, maxHeight: 71),
                alignment: Alignment.center,
                child: Image.file(snapshot.data),
              );
            },
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
        if (channel.locked) AppIcons.lockChannel,
      ];
      content = GestureDetector(
        onTap: () { widget.onChannelTap(channel); },
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

  Widget get _hexChannelGrid {
    _iterator = widget.channels.iterator;
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

  Widget _listTileBuilder(BuildContext context, int index) {
    Channel channel = widget.channels[index];
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      onTap: () { widget.onChannelTap(channel); },
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
      itemBuilder: _listTileBuilder,
      separatorBuilder: (BuildContext context, int id) => Divider(height: 0,),
      itemCount: widget.channels.length,
    );
  }

  Widget _blockTileBuilder(Channel channel, int oddity) {
    EdgeInsetsGeometry margin;
    if (oddity < 1) {
      margin = EdgeInsets.only(right: 2.5);
    } else if (oddity > 1) {
      margin = null;
    } else {
      margin = EdgeInsets.only(left: 2.5);
    }
    return GestureDetector(
      onTap: () { widget.onChannelTap(channel); },
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
                id > widget.channels.length - 3 ? 5 : 0),
            child: IntrinsicHeight (
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _blockTileBuilder(widget.channels[id], oddity)
                  ),
                  Expanded(
                    child: id < widget.channels.length - 1
                      ? _blockTileBuilder(widget.channels[id + 1], oddity + 1)
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
                id == widget.channels.length - 1 ? 5 : 0),
            child: _blockTileBuilder(widget.channels[id], oddity),
          );
        } else {
          // empty widget which takes no space and never displayed.
          return const SizedBox();
        }
      },
      itemCount: widget.channels.length,
    );
  }

  Widget build(BuildContext context) {
    switch (widget.listType) {
      case ChannelListType.hexagonal:
        return _hexChannelGrid;
      case ChannelListType.list:
        return _channelList;
      case ChannelListType.blocks:
        return _channelBlockList;
      default:
        return _hexChannelGrid;
    }
  }
}
