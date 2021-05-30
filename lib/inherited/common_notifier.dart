import 'package:flutter/material.dart';


// Assume T in the class and T in the of context is the same when using it!
class CommonNotifier<T> extends InheritedNotifier<ValueNotifier<T>> {
  const CommonNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<T> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static CommonNotifier of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CommonNotifier<T>>();
  }

  T get value => notifier.value;
}
