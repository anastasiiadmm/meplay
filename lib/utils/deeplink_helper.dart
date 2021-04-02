import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';


// patterns for exact match
const routePatterns = [
  '/',
  '/profile',
  '/tv',
  '/favorites',
  '/favorites/tv',
  '/login',
  '/tv/[0-9]+'
];


class DeeplinkHelper {
  BuildContext _context;
  StreamSubscription _sub;
  bool _navigated = false;

  DeeplinkHelper._(BuildContext context)
      : _context = context;

  static DeeplinkHelper _instance;
  static DeeplinkHelper get instance => _instance;

  static DeeplinkHelper initialize(BuildContext context) {
    _instance = DeeplinkHelper._(context);
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
    print(link);
    String path = _getPath(link);
    // TODO: check, if route is the same
    if(_pathExists(path)) {
      // TODO: pop, if it's a player
      Navigator.of(_context).pushNamed(path);
      _navigated = true;
    }
  }

  bool _pathExists(String path) {
    for (String pattern in routePatterns) {
      if(RegExp('^' + pattern + r'$').hasMatch(path)) {
        return true;
      }
    }
    return false;
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
