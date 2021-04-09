import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

import '../router.dart';


const deeplinkPatterns = [
  '/',
  '/login',
  '/profile',
  '/tv',
  '/tv/[0-9]+',
  '/radio',
  '/radio/[0-9]+',
  '/favorites',
  '/favorites/tv',
  '/favorites/radio',
];


const playerPatterns = [
  '/tv/[0-9]+',
  '/radio/[0-9]+',
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
      // TODO: better logic
      navState.popUntil((route) => route.isFirst);
      if(path != '/') navState.pushNamed(path);
      _navigated = true;
    }
  }

  bool _pathAllowed(String path) {
    return deeplinkPatterns.any((pattern) => _toRegex(pattern).hasMatch(path));
  }

  bool _isPlayer(String path) {
    return playerPatterns.any((pattern) => _toRegex(pattern).hasMatch(path));
  }

  bool _isModal(String path) {
    return path.startsWith('/modal');
  }

  bool _isSame(String path1, String path2) {
    if(path1 == path2) return true;
    return playerPatterns.any((pattern) {
      RegExp re = _toRegex(pattern);
      return re.hasMatch(path1) && re.hasMatch(path2);
    });
  }

  RegExp _toRegex(String pattern) {
    if(!pattern.startsWith('^')) pattern = '^$pattern';
    if(!pattern.endsWith(r'$')) pattern = pattern + r'$';
    return RegExp(pattern);
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
