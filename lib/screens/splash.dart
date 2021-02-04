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
      color = AppColors.transparent;
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
              color: AppColors.transparent,
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


final _hexBackground = SplashHexBackground();


class SplashScreen extends StatefulWidget {
  final void Function(void Function() hideCallback) afterShow;
  final void Function() afterHide;

  SplashScreen({Key key, @required this.afterShow, @required this.afterHide})
      : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  double _opacity;
  Curve _curve;
  Duration _animationDuration = Duration(milliseconds: 1500);
  Duration _waitDuration = Duration(milliseconds: 2000);

  void initState() {
    super.initState();
    _opacity = 0;
    _curve = Curves.easeOut;
    Timer.run(show);
  }

  void show() {
    setState(() {
      _opacity = 1;
    });
    Timer(_animationDuration + _waitDuration, () {
      widget.afterShow(hide);
    });
  }

  void hide() {
    setState(() {
      _curve = Curves.easeIn;
      _opacity = 0;
    });
    Timer(_animationDuration, widget.afterHide);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _animationDuration,
      curve: _curve,
        child: Material (
        color: AppColors.megaPurple,
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
    );
  }
}
