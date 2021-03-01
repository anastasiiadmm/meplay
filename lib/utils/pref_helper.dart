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

  static Future<T> loadObject<T>(String key) async {
    SharedPreferences prefs = await(_prefs);
    if (!prefs.containsKey(key)) return null;
    Map<String, dynamic> data = jsonDecode((await _prefs).getString(key));
    return (T as dynamic).fromJson(data);
  }

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
}
