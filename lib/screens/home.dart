import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import 'channelList.dart';


class HomeScreen extends StatefulWidget {
  final void Function() watchTv;
  final void Function() listenToRadio;
  final void Function() watchCinema;

  @override
  HomeScreen({Key key, this.watchTv, this.listenToRadio, this.watchCinema})
      : super(key: key);

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
    if (widget.watchTv != null) {
      widget.watchTv();
    }
  }

  void _listenRadio() {
    if (widget.listenToRadio != null) {
      widget.listenToRadio();
    }
  }

  void _watchCinema() {
    if (widget.watchCinema != null) {
      widget.watchCinema();
    }
  }

  HexagonWidget tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == logoTile) {
      color = AppColors.gray5;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: AppIcons.logo,
          ),
          Text('MePlay', style: AppFonts.logoTitle,),
        ],
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
            Text('ТВ КАНАЛЫ', style: AppFonts.homeBtns,),
          ],
        ),
      );
    } else if (point == radioButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: _listenRadio,
        child: Opacity(
          opacity: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                child: AppIcons.radio,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
              Text('РАДИО', style: AppFonts.homeBtns,),
            ],
          ),
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
              Text('КИНОТЕАТР', style: AppFonts.homeBtns,),
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
          margin: EdgeInsets.only(bottom: 60),
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
