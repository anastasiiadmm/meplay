import 'package:flutter/material.dart';
import '../hexagon_type.dart';
import '../hexagon_widget.dart';

enum GridType { EVEN, ODD, RADIAL }

extension _GridTypeExtension on GridType {
  bool displace(int mainIndex, int crossIndex,
      int crossCount, bool symmetrical) {
    if (crossIndex == 0) {
      return this.displaceFront(mainIndex);
    } else if (crossIndex == crossCount - 1) {
      return this.displaceBack(mainIndex, symmetrical);
    }
    return false;
  }

  bool displaceFront(int index) {
    return (this == GridType.ODD && index.isOdd) ||
        (this == GridType.EVEN && index.isEven);
  }

  bool displaceBack(int index, bool symmetrical) {
    if (symmetrical) {
      return (this == GridType.ODD && index.isOdd) ||
          (this == GridType.EVEN && index.isEven);
    } else {
      return (this == GridType.ODD && index.isEven) ||
          (this == GridType.EVEN && index.isOdd);
    }
  }

  bool removeSym(int index) {
    return this == GridType.EVEN && index.isOdd ||
        this == GridType.ODD && index.isEven;
  }
}

class HexagonOffsetGrid extends StatelessWidget {
  final HexagonType hexType;
  final GridType gridType;

  final int columns;
  final int rows;
  final Color color;
  final double hexagonPadding;
  final double hexagonBorderRadius;
  final double hexagonWidth;
  final double hexagonHeight;
  final bool symmetrical;
  final Widget Function(HexGridPoint point) buildChild;
  final HexagonWidget Function(HexGridPoint point) buildHexagon;

  ///Grid of flat hexagons with odd columns starting with tile and even with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all hexagon tiles. Will be overridden by template padding.
  ///
  /// [hexagonBorderRadius] - Sets border radius for hexagons. Does not depend on size of the hexagons.
  ///
  /// [hexagonWidth] - Desired width of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [hexagonHeight] - Desired height of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [symmetrical] - Whether or not this grid is symmetrical along the cross-axis. If true, last tile from each even column will be removed.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.oddFlat({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding,
    this.hexagonBorderRadius: 0,
    this.hexagonWidth,
    this.hexagonHeight,
    this.symmetrical = false,
  })  : assert(columns > 0),
        assert(rows > 0),
        this.hexType = HexagonType.FLAT,
        this.gridType = GridType.ODD;

  ///Grid of flat hexagons with even columns starting with tile and odd with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all hexagon tiles. Will be overridden by template padding.
  ///
  /// [hexagonBorderRadius] - Sets border radius for hexagons. Does not depend on size of the hexagons.
  ///
  /// [hexagonWidth] - Desired width of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [hexagonHeight] - Desired height of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [symmetrical] - Whether or not this grid is symmetrical along the cross-axis. If true, last tile from each odd column will be removed.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.evenFlat({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding,
    this.hexagonBorderRadius: 0,
    this.hexagonWidth,
    this.hexagonHeight,
    this.symmetrical = false,
  })  : this.hexType = HexagonType.FLAT,
        this.gridType = GridType.EVEN;

  ///Grid of pointy hexagons with odd rows starting with tile and even with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all hexagon tiles. Will be overridden by template padding.
  ///
  /// [hexagonBorderRadius] - Sets border radius for hexagons. Does not change with their size.
  ///
  /// [hexagonWidth] - Desired width of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [hexagonHeight] - Desired height of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [symmetrical] - Whether or not this grid is symmetrical along the cross-axis. If true, last tile from each even row will be removed.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.oddPointy({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding,
    this.hexagonBorderRadius: 0,
    this.hexagonWidth,
    this.hexagonHeight,
    this.symmetrical = false,
  })  : this.hexType = HexagonType.POINTY,
        this.gridType = GridType.ODD;

  ///Grid of pointy hexagons with even rows starting with tile and odd with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all hexagon tiles. Will be overridden by template padding.
  ///
  /// [hexagonBorderRadius] - Sets border radius for hexagons. Does not depend on size of the hexagons.
  ///
  /// [hexagonWidth] - Desired width of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [hexagonHeight] - Desired height of hexagon. Has precedence over size calculated from row/column count.
  ///
  /// [symmetrical] - Whether or not this grid is symmetrical along the cross-axis. If true, last tile from each odd row will be removed.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.evenPointy({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding,
    this.hexagonBorderRadius: 0,
    this.hexagonWidth,
    this.hexagonHeight,
    this.symmetrical = false,
  })  : this.hexType = HexagonType.POINTY,
        this.gridType = GridType.EVEN;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = _hexSize(constraints.maxWidth, constraints.maxHeight);
        var edgeInsets = EdgeInsets.symmetric(
          vertical: _displaceColumns *
              (size.height / (8 * hexType.pointyFactor(false))),
          horizontal:
          _displaceRows * (size.width / (8 * hexType.flatFactor(false))),
        );
        return Container(
          color: color,
          padding: edgeInsets,
          child: _mainAxis(
            (mainCount) => List.generate(
              mainCount,
              (mainIndex) => _crossAxis(
                mainIndex,
                (crossCount) => List.generate(crossCount, (crossIndex) {
                  if (gridType.displace(mainIndex, crossIndex,
                      crossCount, symmetrical)) {
                    //return container with half the size of the hexagon for displaced row/column
                    return Container(
                      width: hexType.isPointy ? size.width / 2 : null,
                      height: hexType.isFlat ? size.height / 2 : null,
                    );
                  }
                  //calculate human readable column & row
                  final col = (hexType.isPointy
                      ? (crossIndex -
                      (gridType.displaceFront(mainIndex) ? 1 : 0))
                      : mainIndex);
                  final row = hexType.isPointy
                      ? mainIndex
                      : (crossIndex -
                      (gridType.displaceFront(mainIndex) ? 1 : 0));
                  final HexGridPoint point = HexGridPoint(row, col);
                  var hexagonTemplate = buildHexagon?.call(point);

                  if (buildHexagon != null && hexagonTemplate == null) {
                    //create default template when no build function or nothing generated
                    hexagonTemplate =
                        HexagonWidget.template(color: Colors.transparent);
                  } else if (hexagonTemplate?.isTemplate != true) {
                    //if null or not a template then override with default template
                    hexagonTemplate = HexagonWidget.template();
                  }
                  //use template values
                  return hexagonTemplate?.copyWith(
                    type: hexType,
                    inBounds: false,
                    padding: hexagonPadding,
                    borderRadius: hexagonBorderRadius,
                    width: hexType.isPointy ? size.width : null,
                    height: hexType.isFlat ? size.height : null,
                    child: buildChild != null
                        ? buildChild.call(point)
                        : hexagonTemplate.child,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mainAxis(List<Widget> Function(int count) children) {
    if (hexType.isPointy) {
      return Column(children: children.call(rows + _displaceRows));
    }
    return Row(children: children.call(columns + _displaceColumns));
  }

  Widget _crossAxis(int mainIndex, List<Widget> Function(int count) children) {
    int removeSym = (symmetrical && gridType.removeSym(mainIndex)) ? 1 : 0;
    if (hexType.isPointy) {
      return Row(children: children.call(
        columns + _displaceColumns - removeSym
      ));
    } else {
      return Column(children: children.call(
        rows + _displaceRows - removeSym
      ));
    }
  }

  int get _displaceColumns => hexType.isPointy ? 1 : 0;

  int get _displaceRows => hexType.isFlat ? 1 : 0;

  Size _hexSize(double maxWidth, double maxHeight) {
    if (hexagonWidth != null && hexagonHeight != null) {
      return Size(hexagonWidth, hexagonHeight);
    } else if (hexagonWidth != null) {
      return Size(hexagonWidth, hexagonWidth / hexType.ratio);
    } else if (hexagonHeight != null) {
      return Size(hexagonHeight * hexType.ratio, hexagonHeight);
    } else if (maxWidth.isFinite) {
      if (hexType.isFlat) {
        var quarters = maxWidth / (1 + (0.75 * (columns - 1)));
        var size = Size(quarters, quarters * hexType.ratio);
        return size * hexType.flatFactor(false);
      }
      var half = maxWidth / (columns * 2 + _displaceColumns);
      return Size(half * 2, half * 2 * hexType.ratio);
    } else if (maxHeight.isFinite) {
      if (hexType.isPointy) {
        var quarters = maxHeight / (1 + (0.75 * (rows - 1)));
        var size = Size(quarters / hexType.ratio, quarters);
        return size * hexType.pointyFactor(false);
      }
      var half = (maxHeight - 0) / (rows * 2 + _displaceRows);
      return Size(half * 2 / hexType.ratio, half * 2);
    } else {
      throw Exception('Error: Infinite constraints in both dimensions!');
    }
  }
}

class HexGridSize {
  const HexGridSize(this.rows, this.cols);

  final int rows;
  final int cols;

  bool operator ==(Object other) {
    return other is HexGridSize
        && other.rows == this.rows
        && other.cols == this.cols;
  }

  @override
  int get hashCode => super.hashCode;
}

class HexGridPoint {
  const HexGridPoint(this.row, this.col);

  final int row;
  final int col;

  bool operator ==(Object other) {
    return other is HexGridPoint
        && other.row == this.row
        && other.col == this.col;
  }

  @override
  int get hashCode => super.hashCode;
}
