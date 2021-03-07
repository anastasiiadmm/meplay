import 'dart:async';

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

  static Future<void> initialize() async {
    _instance = NotificationHelper._();
    await _instance._initFirebase();
    await _instance._initLocal();
    await _instance._initChannel();
  }

  String get fcmToken => _fcmToken;

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen(_fgMessageHandler);
    FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_remoteMessageOpen);
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

  Future<void> sendToken() async {
    return ApiClient.saveFCMToken(_fcmToken);
  }

  Future<void> _initLocal() async {
    _localPlugin = FlutterLocalNotificationsPlugin();
    final InitializationSettings settings =
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(
          onDidReceiveLocalNotification: _localMsgHandler,
        ),
        macOS: MacOSInitializationSettings(),  // empty
      );
    await _localPlugin.initialize(
      settings,
      onSelectNotification: _localMsgOpen,
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
  Future<void> _localMsgHandler(int id, String title,
      String body, String payload) async {
    print("\nLOCAL\n$id\n$title\n$body\n$payload\n");
  }

  // Handles app opening when local notification tapped
  Future<void> _localMsgOpen(String payload) async {
    print("\nLOCAL OPEN\n$payload\n");
  }

  // Handles fb messages received while app in foreground
  Future<void> _fgMessageHandler(RemoteMessage message) async {
    _logMessage(message, type: 'FOREGROUND');

    RemoteNotification notification = message.notification;
    if (notification != null) {
      showNotification(
        message.hashCode,
        notification.title,
        notification.body,
      );
    }
  }

  // Handles app opening when remote message tapped
  Future<void> _remoteMessageOpen(RemoteMessage message) async {
    _logMessage(message, type: 'OPEN WITH');
    // this may open specific screen or something,
    // depending on the message payload
  }

  // Need to be called somewhere to get the message which opened the app.
  // from terminated state.
  Future<RemoteMessage> getInitialMessage() async {
    RemoteMessage message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null)
      _logMessage(message, type: 'INITIAL');
    return message;
  }

  void showNotification(int id, String title, String text) {
    _localPlugin.show(
      id, title, text,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          _channel.description,
        ),
      ),
    );
  }

  // Handles fb messages received while app in background
  // doc says it should be top level function, static method may also work
  static Future<void> _bgMessageHandler(RemoteMessage message) async {
    _logMessage(message, type: 'BACKGROUND');
  }

  // helper function for logging Firebase messages
  static void _logMessage(RemoteMessage message, {String type: 'ANY'}) {
    print('\nReceived firebase message of type $type, id: ${message.messageId}');
    print('data: ${message.data}');
    if (message.notification != null) {
      print("notification: ${message.notification}\n");
    }
  }
}


// store last 50 messages to the database (title, text, id, date) including scheduled

// schedule local program messages
// handle local program messages to open specific channel.
