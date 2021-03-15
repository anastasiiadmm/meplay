import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

import '../api_client.dart';
import 'tz_helper.dart';


class NotificationHelper {
  static NotificationHelper _instance;
  FlutterLocalNotificationsPlugin _localPlugin;
  AndroidNotificationChannel _channel;
  String _fcmToken;

  NotificationHelper._();

  static NotificationHelper get instance => _instance;

  static Future<NotificationHelper> initialize() async {
    _instance = NotificationHelper._();
    await _instance._initFirebase();
    await _instance._initLocal();
    await _instance._initChannel();
    return _instance;
  }

  String get fcmToken => _fcmToken;

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen(_remoteFgHandler);
    FirebaseMessaging.onBackgroundMessage(_remoteBgHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_remoteOpenHandler);
    await _initToken();
  }

  Future<void> _initToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    sendToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      if (token != _fcmToken) {
        _fcmToken = token;
        sendToken();
      }
    });
  }

  Future<void> _initLocal() async {
    _localPlugin = FlutterLocalNotificationsPlugin();
    final InitializationSettings settings =
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(
          onDidReceiveLocalNotification: _localHandler,
        ),
        macOS: MacOSInitializationSettings(),  // empty
      );
    await _localPlugin.initialize(
      settings,
      onSelectNotification: _localOpenHandler,
    );
  }

  Future<void> _initChannel() async {
    _channel = AndroidNotificationChannel(
      'me_play_channel',  // id, also set in main AndroidManifest.
      'Уведомления MePlay',  // title
      'Уведомления MePlay',  // description
      importance: Importance.max,
    );
    _localPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // handles local messages received
  Future<void> _localHandler(int id, String title,
      String body, String payload) async {
    print("\nLOCAL\n$id\n$title\n$body\n$payload\n");

  }

  // handles local messages opening the app
  Future<void> _localOpenHandler(String payload) async {
    if (payload.isNotEmpty) {
      print("\nLOCAL OPEN\n$payload\n");

    }
  }

  // handles remote messages received in foreground
  Future<void> _remoteFgHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE FOREGROUND');

    RemoteNotification notification = message.notification;
    if (notification != null) {
      show(
        message.hashCode,
        notification.title,
        notification.body,
        payload: jsonEncode(message.data),
      );
    }
  }

  // handles remote messages taps opening the app
  Future<void> _remoteOpenHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE OPEN');

  }

  // handles remote messages received in background
  static Future<void> _remoteBgHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE BACKGROUND');

  }

  // log firebase messages
  static void _logRemote(RemoteMessage message, {String type: 'ANY'}) {
    print('\nReceived remote message of type $type, id: ${message.messageId}');
    print('data: ${message.data}');
    if (message.notification != null) {
      print("notification: ${message.notification}\n");
    }
  }

  // gets initial message from background
  Future<RemoteMessage> getInitialMessage() async {
    RemoteMessage initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null)
      _logRemote(initial, type: 'REMOTE INITIAL');
    return initial;
  }

  Future<void> sendToken() async {
    print('FCM token: $_fcmToken');
    return ApiClient.saveFCMToken(_fcmToken);
  }

  void show(int id, String title, String text, {String payload}) {
    _localPlugin.show(
      id, title, text,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          _channel.description,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> schedule(String title, String text,
      DateTime time, Map<String, dynamic> data) async {
    TZDateTime scheduleTime = TZHelper.fromNaive(time);
    TZDateTime now = TZHelper.now();
    if (scheduleTime.isBefore(now)) {
      scheduleTime = now.add(Duration(seconds: 3));
    }
    data['time'] = time.toIso8601String();
    await _localPlugin.zonedSchedule(
      now.millisecondsSinceEpoch.hashCode,
      title,
      text,
      time,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          _channel.description,
        ),
      ),
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: jsonEncode(data),
    );
  }

  Future<void> cancel(int id) async {
    await _localPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> list() async {
    return _localPlugin.pendingNotificationRequests();
  }
}
