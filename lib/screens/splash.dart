import 'dart:async';
import 'package:flutter/material.dart';
import '../hexagon/hexagon_widget.dart';
import '../hexagon/grid/hexagon_offset_grid.dart';
import '../hexagon/hexagon_type.dart';
import '../theme.dart';


class SplashHexBackground extends StatelessWidget {
  final _gridSize = HexGridSize(7, 5);
  final _visibleRows = <int>[0, 1, 5, 6];

  HexagonWidget _tileBuilder(HexGridPoint point) {
    Color color;
    if (_visibleRows.contains(point.row)) {
      color = AppColors.emptyTile;
    } else {
      color = Colors.transparent;
    }
    return HexagonWidget.template(color: color);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Container(
          child: Center(
            child: HexagonOffsetGrid.oddPointy(
              columns: _gridSize.cols,
              rows: _gridSize.rows,
              symmetrical: true,
              color: Colors.transparent,
              hexagonPadding: 8,
              hexagonBorderRadius: 15,
              hexagonWidth: 174,
              buildHexagon: _tileBuilder,
            ),
          ),
        ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  final void Function(void Function() hideCallback) afterShow;
  final void Function() afterHide;

  SplashScreen({Key key, @required this.afterShow, @required this.afterHide})
      : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _mainOpacity;
  double _partsOpacity;
  Duration _animationDuration = Duration(seconds: 2);
  final _hexBackground = SplashHexBackground();

  void initState() {
    super.initState();
    _mainOpacity = 0;
    _partsOpacity = 1;
    Timer.run(show);
  }

  void show() {
    setState(() {
      _mainOpacity = 1;
    });
    Timer(_animationDuration, () {widget.afterShow(hide);});
  }

  void hide() {
    setState(() {
      _partsOpacity = 0;
    });
    Timer(_animationDuration, widget.afterHide);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _mainOpacity,
      duration: _animationDuration,
      child: Material (
        color: AppColors.megaPurple,
        child: AnimatedOpacity(
          opacity: _partsOpacity,
          duration: _animationDuration,
          child: Stack(
            children: [
              _hexBackground,
              Center(
                child: HexagonWidget(
                  type: HexagonType.POINTY,
                  width: 242,
                  color: AppColors.gray5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: AppIcons.splash,
                      ),
                      Text('MePlay', style: AppFonts.splashTitle,),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
