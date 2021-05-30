import 'package:flutter/material.dart';
import '../models.dart';


class NewsNotifier extends InheritedNotifier<ValueNotifier<List<News>>> {
  const NewsNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<List<News>> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static NewsNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NewsNotifier>();
  }

  List<News> get news => notifier.value;
}
