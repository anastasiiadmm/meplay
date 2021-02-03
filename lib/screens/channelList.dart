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
    color = AppColors.emptyTile;
    return HexagonWidget.template(color: color, child: content);
  }

  Widget get _body {
    HexGridSize gridSize = HexGridSize(7, 6);

    return ClipRect(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 1,
        scaleEnabled: false,
        constrained: false,
        child: HexagonOffsetGrid.oddPointy(
          columns: gridSize.cols,
          rows: gridSize.rows,
          symmetrical: true,
          color: Colors.transparent,
          hexagonPadding: 8,
          hexagonBorderRadius: 15,
          hexagonWidth: 174,
          buildHexagon: tileBuilder,
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
