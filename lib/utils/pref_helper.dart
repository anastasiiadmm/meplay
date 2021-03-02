import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


abstract class PrefKeys {
  static const channelListType = 'channelListType';
  static const user = 'user';

  static String videoAR(int channelId) => 'videoAR$channelId';
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
    String data;
    if (prefs.containsKey(key))
      data = prefs.getString(key);
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
      [dynamic Function(Map<String, dynamic> data) restore,]
  ) async {
    SharedPreferences prefs = await(_prefs);
    Map<String, dynamic> data;
    if (prefs.containsKey(key))
      data = jsonDecode(prefs.getString(key));
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
