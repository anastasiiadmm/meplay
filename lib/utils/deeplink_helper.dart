import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

import '../main.dart';


const allowedPathPatterns = [
  '/',
  '/profile',
  '/tv',
  '/favorites',
  '/favorites/tv',
  '/tv/[0-9]+'
];


class DeeplinkHelper {
  StreamSubscription _sub;
  bool _navigated = false;

  DeeplinkHelper._();

  static DeeplinkHelper _instance;
  static DeeplinkHelper get instance {
    if(_instance == null) init();
    return _instance;
  }

  static DeeplinkHelper init() {
    _instance = DeeplinkHelper._();
    _instance._subscribe();
    return _instance;
  }

  bool get navigated => _navigated;

  void _subscribe() {
    _sub = getLinksStream().listen(
      navigateTo,
      onError: (e) => print(e),
    );
  }

  Future<void> checkInitialLink() async {
    try {
      String initialLink = await getInitialLink();
      if (initialLink != null) {
        navigateTo(initialLink);
      }
    } on PlatformException catch(e) {
      print(e);
    }
  }

  void navigateTo(String link) {
    String path = _getPath(link);
    print("$link : $path");
    if(_pathAllowed(path)) {
      NavigatorState navState = navigatorKey.currentState;
      // todo add NavigatorObserver to manage history
      // if player - replace channel
      // prevent same path pushing
      navState.pushNamed(path);
      _navigated = true;
    }
  }

  bool _pathAllowed(String path) {
    return allowedPathPatterns.any((pattern) => RegExp(
      '^' + pattern + r'$',
    ).hasMatch(path));
  }

  String _getPath(String link) {
    String path = link.trim()
        .replaceAll('http://teleclick.kg/deeplinks', '')
        .replaceAll('https://teleclick.kg/deeplinks', '')
        .replaceAll('meplay://teleclick.kg', '');
    if(path == '') path = '/';
    return path;
  }

  void dispose() {
    _sub.cancel();
  }
}
