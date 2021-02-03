import 'dart:math';

import 'package:flutter/material.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../models.dart';
import '../theme.dart';


class ChannelListScreen extends StatefulWidget {
  final List<Channel> channels;

  ChannelListScreen({Key key, this.channels}): super();

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}


class _ChannelListScreenState extends State<ChannelListScreen> {
  HexGridSize _gridSize;
  List<Channel> _channels;
  Iterator _iterator;

  @override
  void initState() {
    super.initState();
    _channels = widget.channels..sort(
      (ch1, ch2) => ch1.number.compareTo(ch2.number)
    );
  }

  void _calcGridSize() {
    int rows = max(sqrt(_channels.length).floor(), 5);
    int cols = max((_channels.length / rows).ceil(), 4);
    _gridSize = HexGridSize(rows + 2, cols + 1);
  }

  void _onNavTap(int index) {
    Navigator.of(context).pop(index);
  }

  Widget get _bottomBar {
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomBar,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: _onNavTap,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.home,
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.star,
          label: 'Избранное',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.user,
          label: 'Профиль',
        ),
      ],
    );
  }

  HexagonWidget tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if(point.row == 0
        || point.row == _gridSize.rows - 1
        || point.row % 2 == 0 && point.col == 0
        || point.row % 2 != 0 && point.col == _gridSize.cols - 1
        || !_iterator.moveNext()){
      color = AppColors.emptyTile;
    } else {
      color = AppColors.white;
      Channel channel = _iterator.current;
      content = GestureDetector(
        onTap: () {print(channel.number);},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${channel.number}',
              style: AppFonts.inputHint,
            ),
            Text(
              channel.name,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return HexagonWidget.template(color: color, child: content,);
  }

  Widget get _body {
    _iterator = _channels.iterator;
    _calcGridSize();

    return ClipRect(
      child: OverflowBox (
        maxWidth: MediaQuery.of(context).size.width + 160,
        maxHeight: MediaQuery.of(context).size.height + 130,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 1,
          scaleEnabled: false,
          constrained: false,
          child: HexagonOffsetGrid.oddPointy(
            columns: _gridSize.cols,
            rows: _gridSize.rows,
            color: Colors.transparent,
            hexagonPadding: 8,
            hexagonBorderRadius: 15,
            hexagonWidth: 174,
            buildHexagon: tileBuilder,
          ),
        ),
      ),
    );
  }

  Widget get _appBar {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      extendBody: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
