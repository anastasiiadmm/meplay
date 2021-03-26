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
  final bool isSplashShowing;
  final void Function() onShow;
  final void Function() onHide;

  SplashScreen({
    Key key,
    this.isSplashShowing = true,
    this.onShow,
    this.onHide,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  double _opacity;
  Duration _animationDuration = const Duration(milliseconds: 1500);
  Duration _waitDuration = const Duration(milliseconds: 2000);

  void initState() {
    super.initState();
    _opacity = widget.isSplashShowing ? 0 : 1;
  }

  void show() {
    Timer.run(() {
      setState(() { _opacity = 1; });
      if (widget.onShow != null) {
        Timer(_animationDuration + _waitDuration, widget.onShow);
      }
    });
  }

  void hide() {
    Timer.run(() {
      setState(() { _opacity = 0; });
      if (widget.onHide != null) {
        Timer(_animationDuration, widget.onHide);
      }
    });
  }

  void toggle() {
    if(widget.isSplashShowing) {
      if(_opacity != 1) show();
    } else {
      if(_opacity != 0) hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    toggle();
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _animationDuration,
      curve: Curves.linear,
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
