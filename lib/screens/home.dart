import 'package:flutter/material.dart';
import 'base.dart';
import '../theme.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';


class HomeScreen extends StatefulWidget {
  final Function(NavItem item) onMenuTap;

  @override
  HomeScreen({Key key, this.onMenuTap}): super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final gridSize = HexGridSize(7, 5);
  final logoTile = HexGridPoint(2, 2);
  final tvButton = HexGridPoint(3, 1);
  final radioButton = HexGridPoint(3, 2);
  final cinemaButton = HexGridPoint(4, 2);

  void _watchTV() {
    widget.onMenuTap(NavItem.tv);
  }

  void _listenRadio() {
    widget.onMenuTap(NavItem.radio);
  }

  void _watchCinema() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Онлайн-кинотеатр'),
        content: Text('Находится в разработке.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Закрыть')
          )
        ],
      ),
    );
  }

  HexagonWidget tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == logoTile) {
      color = AppColors.gray5;
      content = Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: AppIcons.logo,
      );
    } else if (point == tvButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: _watchTV,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: AppIcons.tv,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            ),
            Text('ТВ КАНАЛЫ', style: AppFonts.homeButtons,),
          ],
        ),
      );
    } else if (point == radioButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: _listenRadio,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: AppIcons.radio,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            ),
            Text('РАДИО', style: AppFonts.homeButtons,),
          ],
        ),
      );
    } else if (point == cinemaButton) {
      color = AppColors.gray10;
      content = content = GestureDetector(
        onTap: _watchCinema,
        child: Opacity(
          opacity: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                child: AppIcons.cinema,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
              Text('КИНОТЕАТР', style: AppFonts.homeButtons,),
            ],
          ),
        ),
      );
    } else {
      color = AppColors.emptyTile;
    }
    return HexagonWidget.template(color: color, child: content);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Center(
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
        ),
      ),
    );
  }
}
