import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


abstract class PrefKeys {
  static const listType = 'chlistType';
  static const user = 'user';

  static String ratio(int channelId) => 'ratio$channelId';
}


abstract class PrefHelper {
  static Future<void> saveString(
      String key, dynamic object, {bool overwrite: true}
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!overwrite && prefs.containsKey(key)) return;
    prefs.setString(key, object.toString());
  }

  static Future<dynamic> loadString(
      String key,
      [dynamic Function(String data) restore,]
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!prefs.containsKey(key)) return null;
    String data = prefs.getString(key);
    if (restore == null) return data;
    return restore(data);
  }

  static Future<void> saveJson(
      String key, dynamic object, {bool overwrite: true}
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!overwrite && prefs.containsKey(key)) return;
    prefs.setString(key, jsonEncode(object));
  }

  static Future<dynamic> loadJson(
      String key,
      [dynamic Function(dynamic data) restore,]
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!prefs.containsKey(key)) return null;
    dynamic data = jsonDecode(prefs.getString(key));
    if (restore == null) return data;
    return restore(data);
  }

  static Future<void> clear(String key) async {
    SharedPreferences prefs = await(_prefs);
    if (prefs.containsKey(key)) prefs.remove(key);
  }

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
}