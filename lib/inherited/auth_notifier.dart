import 'package:flutter/material.dart';
import '../models.dart';


class AuthNotifier extends InheritedNotifier<ValueNotifier<User>> {
  const AuthNotifier ({
    Key key,
    @required Widget child,
    ValueNotifier<User> notifier,
  }) : super(key: key, child: child, notifier: notifier);

  static AuthNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthNotifier>();
  }

  User get user => notifier.value;
}
