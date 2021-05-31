import 'package:flutter/material.dart';
import '../models.dart';


class PopularNotifier extends InheritedNotifier<ValueNotifier<List<Channel>>> {
  const PopularNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<List<Channel>> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static PopularNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PopularNotifier>();
  }

  List<Channel> get popularChannels => notifier.value;
}
