import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api_client.dart';


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

  // Handles local messages received while app in foreground
  Future<void> _localHandler(int id, String title,
      String body, String payload) async {
    print("\nLOCAL\n$id\n$title\n$body\n$payload\n");

    // show it in foreground then remove
  }

  // Handles app opening when local message tapped
  // works from foreground.
  Future<void> _localOpenHandler(String payload) async {
    if (payload.isNotEmpty) {
      print("\nLOCAL OPEN\n$payload\n");
      // handle
    }
  }

  // Handles remote messages received in foreground
  // and turns them into local.
  Future<void> _remoteFgHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE FOREGROUND');

    RemoteNotification notification = message.notification;
    if (notification != null) {
      showNotification(
        message.hashCode,
        notification.title,
        notification.body,
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handles app opening when remote message tapped
  // works from background.
  Future<void> _remoteOpenHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE OPEN');

    // this may open specific screen or something,
    // depending on the message payload
  }

  // Handles fcm messages received while app in background
  // doc says it should be top level function, static method may also work
  static Future<void> _remoteBgHandler(RemoteMessage message) async {
    _logRemote(message, type: 'REMOTE BACKGROUND');
  }

  // helper function for logging Firebase messages
  static void _logRemote(RemoteMessage message, {String type: 'ANY'}) {
    print('\nReceived remote message of type $type, id: ${message.messageId}');
    print('data: ${message.data}');
    if (message.notification != null) {
      print("notification: ${message.notification}\n");
    }
  }

  // Call this somewhere on app start to get initial remote message,
  // which opened the app from terminated state.
  Future<RemoteMessage> getInitialMessage() async {
    RemoteMessage initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null)
      _logRemote(initial, type: 'REMOTE INITIAL');
    return initial;
  }

  Future<void> sendToken() async {
    return ApiClient.saveFCMToken(_fcmToken);
  }

  void showNotification(int id, String title, String text, {String payload}) {
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

  void scheduleLocal(String title, String body,
      String payload, DateTime time) async {

    // convert time to tztime
    // create notification
    // schedule it
    // add it to list
  }
}


// store last 50 messages to the database (title, text, id, date) including scheduled

// todo: make some notifications repeatable - daily, weekly or monthly at the same time.
