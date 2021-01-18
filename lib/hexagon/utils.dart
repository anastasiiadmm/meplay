import 'dart:math';

import 'package:flutter/material.dart';

import 'hexagon_type.dart';

class HexagonUtils {
  static Point flatHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  static Point pointyHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i - 30;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  /// Calculates hexagon corners for given size and with given center.
  static List<Point> flatHexagonCornerList(Offset center, double size) {
    List<Point> corners = List(6);
    for (int i = 0; i < 6; i++) {
      corners[i] = flatHexagonCorner(center, size, i);
    }

    return corners;
  }

  /// Calculates hexagon corners for given size and with given center.
  static List<Point> pointyHexagonCornerList(Offset center, double size) {
    List<Point> corners = List(6);
    for (int i = 0; i < 6; i++) {
      corners[i] = pointyHexagonCorner(center, size, i);
    }
    return corners;
  }

  static Point pointAtDistance(Point start, Point end,
      {double distance, double fraction}) {
    double xLength = end.x - start.x;
    double yLength = end.y - start.y;
    if (fraction == null) {
      if (distance == null) {
        throw Exception('Distance or fraction should be specified.');
      }
      double length = sqrt(xLength * xLength + yLength * yLength);
      fraction = distance / length;
    }
    return Point(start.x + xLength * fraction, start.y + yLength * fraction);
  }

  static Point radiusStart(Point corner, int index,
      List<Point> cornerList, double radius) {
    Point prevCorner = index > 0
        ? cornerList[index - 1]
        : cornerList[cornerList.length - 1];
    return pointAtDistance(corner, prevCorner, distance: radius);
  }

  static Point radiusEnd(Point corner, int index,
      List<Point> cornerList, double radius) {
    Point nextCorner = index < cornerList.length - 1
        ? cornerList[index + 1]
        : cornerList[0];
    return pointAtDistance(corner, nextCorner, distance: radius);
  }

  /// Returns path in shape of hexagon.
  static Path hexagonPath(Size size, HexagonType type,
      {bool inBounds, double borderRadius: 0}) {
    inBounds = inBounds == true;
    final center = Offset(size.width / 2, size.height / 2);

    List<Point> cornerList;
    if (type == HexagonType.FLAT) {
      cornerList = HexagonUtils.flatHexagonCornerList(
          center, size.width / type.flatFactor(inBounds) / 2);
    } else {
      cornerList = HexagonUtils.pointyHexagonCornerList(
          center, size.height / type.pointyFactor(inBounds) / 2);
    }

    final path = Path();
    if (borderRadius > 0) {
      Point rStart;
      Point rEnd;
      cornerList.asMap().forEach((index, point) {
        rStart = radiusStart(point, index, cornerList, borderRadius);
        rEnd = radiusEnd(point, index, cornerList, borderRadius);
        if (index == 0) {
          path.moveTo(rStart.x, rStart.y);
        } else {
          path.lineTo(rStart.x, rStart.y);
        }
        // rough approximation of an circular arc for an 120 deg angle.
        Point control1 = pointAtDistance(rStart, point, fraction: 0.7698);
        Point control2 = pointAtDistance(rEnd, point, fraction: 0.7698);
        path.cubicTo(
          control1.x, control1.y,
          control2.x, control2.y,
          rEnd.x, rEnd.y,
        );
      });
    } else {
      cornerList.asMap().forEach((index, point) {
        if (index == 0) {
          path.moveTo(point.x, point.y);
        } else {
          path.lineTo(point.x, point.y);
        }
      });
    }

    return path..close();
  }
}
