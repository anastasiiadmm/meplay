import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api_client.dart';
import '../models.dart';


// helper function for logging Firebase messages
void _logMessage(RemoteMessage message, {String type: 'ANY'}) {
  print('\nReceived firebase message of type $type, id: ${message.messageId}');
  print('data: ${message.data}');
  if (message.notification != null) {
    print("notification: ${message.notification}\n");
  }
}


// Handles fb messages received while app in background
// doc says it should be top level function
Future<void> _bgMessageHandler(RemoteMessage message) async {
  _logMessage(message, type: 'BACKGROUND');
}


class NotificationHelper {
  static NotificationHelper _instance;
  FlutterLocalNotificationsPlugin _flnp;
  AndroidNotificationChannel _channel;

  NotificationHelper._();

  static NotificationHelper get instance => _instance;

  static Future<void> initialize() async {
    _instance = NotificationHelper._();
    await _instance._initFirebase();
    await _instance._initLocal();
    await _instance._initChannel();
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen(_fgMessageHandler);
    FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_remoteMessageOpen);
    FirebaseMessaging.instance.onTokenRefresh.listen(
        ApiClient.saveFirebaseToken
    );
  }

  Future<void> _initLocal() async {
    _flnp = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final IOSInitializationSettings iOSInitSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification: _localMsgHandler,
    );
    final MacOSInitializationSettings macOSInitSettings = MacOSInitializationSettings();
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
      macOS: macOSInitSettings,
    );
    await _flnp.initialize(
      initSettings,
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
    _flnp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> sendToken([User user]) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String token = await messaging.getToken();
    await ApiClient.saveFirebaseToken(token, user);
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
    _flnp.show(
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
}


// store last 50 messages to the database (title, text, id, date) including scheduled

// schedule local program messages
// handle local program messages to open specific channel.


// TODO: handle ios messages, config and notification
