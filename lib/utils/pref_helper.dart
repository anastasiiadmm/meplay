import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


abstract class PrefHelper {
  static Future<void> saveString(
      String key, String data, {overwrite: true}
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!overwrite && prefs.containsKey(key)) return;
    prefs.setString(key, data);
  }

  static Future<String> loadString(String key) async {
    SharedPreferences prefs = await(_prefs);
    if (!prefs.containsKey(key)) return null;
    return prefs.getString(key);
  }

  static Future<void> clear(String key) async {
    SharedPreferences prefs = await(_prefs);
    if (prefs.containsKey(key)) prefs.remove(key);
  }

  static Future<void> saveObject(
      String key, dynamic object, {overwrite: true}
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!overwrite && prefs.containsKey(key)) return;
    Map<String, dynamic> data = object.toJson();
    prefs.setString(key, jsonEncode(data));
  }

  static Future<T> loadObject<T>(
      String key,
      T Function(Map<String, dynamic> data) restore,
  ) async {
    SharedPreferences prefs = await(_prefs);
    if (!prefs.containsKey(key)) return null;
    Map<String, dynamic> data = jsonDecode(prefs.getString(key));
    return restore(data);
  }

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
}
