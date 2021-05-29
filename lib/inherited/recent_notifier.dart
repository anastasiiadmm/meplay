import 'package:flutter/material.dart';
import '../models.dart';


class RecentNotifier extends InheritedNotifier<ValueNotifier<List<Channel>>> {
  const RecentNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<List<Channel>> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static RecentNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RecentNotifier>();
  }

  List<Channel> get recentChannels => notifier.value;
}
