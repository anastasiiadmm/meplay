import 'package:flutter/material.dart';


class UnreadNewsNotifier extends InheritedNotifier<ValueNotifier<int>> {
  const UnreadNewsNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<int> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static UnreadNewsNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UnreadNewsNotifier>();
  }

  int get count => notifier.value;
}
