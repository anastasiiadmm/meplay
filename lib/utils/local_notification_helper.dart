import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

import 'tz_helper.dart';


class LocalNotificationHelper {
  static LocalNotificationHelper _instance;
  FlutterLocalNotificationsPlugin _plugin;
  AndroidNotificationChannel _channel;
  NotificationDetails _details;

  LocalNotificationHelper._();

  static LocalNotificationHelper get instance => _instance;

  static Future<LocalNotificationHelper> init() async {
    _instance = LocalNotificationHelper._();
    await _instance._initLocal();
    await _instance._initChannel();
    _instance._initDetails();
    return _instance;
  }

  Future<void> _initLocal() async {
    _plugin = FlutterLocalNotificationsPlugin();
    final InitializationSettings settings =
    InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: IOSInitializationSettings(
        onDidReceiveLocalNotification: _onReceive,
      ),
      macOS: MacOSInitializationSettings(),
    );
    await _plugin.initialize(
      settings,
      onSelectNotification: _onOpen,
    );
  }

  Future<void> _initChannel() async {
    _channel = AndroidNotificationChannel(
      'meplay_channel',  // same as in the AndroidManifest
      'Уведомления MePlay',
      'Уведомления MePlay',
      importance: Importance.max,
    );
    _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _initDetails() {
    _details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        _channel.description,
      ),
      iOS: IOSNotificationDetails(),
      macOS: MacOSNotificationDetails(),
    );
  }

  int show(String title, String text, {dynamic data}) {
    int id = _getId();
    _plugin.show(
      id, title, text,
      _details,
      payload: data is String ? data : jsonEncode(data),
    );
    return id;
  }

  Future<int> schedule(String title, String text,
      DateTime time, {Map<String, dynamic> data}) async {
    TZDateTime scheduleTime = _checkTime(time);
    int id = _getId();
    data['time'] = scheduleTime.toIso8601String();
    await _plugin.zonedSchedule(
      id, title, text,
      time, _details,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: jsonEncode(data),
    );
    return id;
  }

  Future<void> cancel(int id) async {
    return _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> list() async {
    return _plugin.pendingNotificationRequests();
  }

  // only for iOS older than 10
  Future<void> _onReceive(int id, String title,
      String body, String payload) async {
    print("\nRECEIVE LOCAL iOS\n$id\n$title\n$body\n$payload\n");

  }

  Future<void> _onOpen(String payload) async {
    if (payload.isNotEmpty) {
      print("\nOPEN LOCAL\n$payload\n");

      // TODO: open channel here if there is a channel in a notification
    }
  }

  TZDateTime _checkTime(DateTime time) {
    TZDateTime scheduleTime = TZHelper.fromNaive(time);
    TZDateTime now = TZHelper.now();
    if (scheduleTime.isBefore(now)) {
      scheduleTime = now.add(Duration(seconds: 3));
    }
    return scheduleTime;
  }

  int _getId() {
    int id = DateTime.now().millisecondsSinceEpoch.hashCode;
    const int maxInt = 2147483648;  // 2^31 - 1
    while (id > maxInt) {
      id = id ~/ 2 - 1;
    }
    return id;
  }

  // TODO: allow schedule periodic.
}