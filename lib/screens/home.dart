import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  final gridSize = HexGridSize(7, 5);
  final logoTile = HexGridPoint(2, 2);
  final tvButton = HexGridPoint(3, 1);
  final radioButton = HexGridPoint(3, 2);
  final cinemaButton = HexGridPoint(4, 2);

  void _watchTV() {

  }

  void _listenToRadio() {

  }

  void _watchCinema() {

  }

  HexagonWidget tileBuilder(HexGridPoint point) {
    Color color;
    Widget content;
    if (point == logoTile) {
      color = AppColors.gray5;
      content = Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
        child: SvgPicture.asset('assets/icons/logo.svg'),
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
              child: SvgPicture.asset('assets/icons/tv.svg'),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            ),
            Text('ТВ КАНАЛЫ', style: AppFonts.homeButtons,),
          ],
        ),
      );
    } else if (point == radioButton) {
      color = AppColors.gray10;
      content = GestureDetector(
        onTap: _listenToRadio,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: SvgPicture.asset('assets/icons/radio.svg'),
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
                child: SvgPicture.asset('assets/icons/cinema.svg'),
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
    return Scaffold(
      backgroundColor: AppColors.megaViolet,
      body: Container(
        child: ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Center(
              child: HexagonOffsetGrid.oddPointy(
                columns: gridSize.cols,
                rows: gridSize.rows,
                symmetrical: true,
                color: Colors.transparent,
                hexagonPadding: 8,
                hexagonBorderRadius: 10,
                hexagonWidth: 174,
                buildHexagon: tileBuilder,
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(items: [
      //   BottomNavigationBarItem(icon: null)
      // ]),
    );
  }
}
