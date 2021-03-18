import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../api_client.dart';
import 'local_notification_helper.dart';
import 'pref_helper.dart';


class FCMMessageHelper {
  static FCMMessageHelper _instance;
  String _fcmToken;

  FCMMessageHelper._();

  static FCMMessageHelper get instance => _instance;

  static Future<FCMMessageHelper> initialize() async {
    _instance = FCMMessageHelper._();
    await _instance._initFirebase();
    await _instance._initToken();
    return _instance;
  }

  String get fcmToken => _fcmToken;

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen(_onReceiveFg);
    FirebaseMessaging.onBackgroundMessage(_onReceiveBg);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpen);
  }

  Future<void> _initToken() async {
    _fcmToken = await _loadToken();
    String token = await FirebaseMessaging.instance.getToken();
    await _updateToken(token);
    print('FCM token: $_fcmToken');
    _updateToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_updateToken);
  }

  Future<void> _updateToken(String token) async {
    if (_fcmToken != token) return _saveToken(token);
  }

  Future<String> _loadToken() async {
    return PrefHelper.loadString(PrefKeys.fcmToken);
  }

  Future<void> _saveToken(token) async {
    _fcmToken = token;
    await PrefHelper.saveString(PrefKeys.fcmToken, token);
    return sendToken();
  }

  // handles remote messages received in foreground
  Future<void> _onReceiveFg(RemoteMessage message) async {
    _log(message, type: 'REMOTE FOREGROUND');

    RemoteNotification notification = message.notification;
    if (notification != null) {
      LocalNotificationHelper.instance.show(
        notification.title,
        notification.body,
        data: message.data,
      );
    }
  }

  // handles remote messages taps opening the app
  Future<void> _onOpen(RemoteMessage message) async {
    _log(message, type: 'REMOTE OPEN');

  }

  // handles remote messages received in background
  // should be top level function or static method according to the docs.
  static Future<void> _onReceiveBg(RemoteMessage message) async {
    _log(message, type: 'REMOTE BACKGROUND');

  }

  // log firebase messages
  static void _log(RemoteMessage message, {String type: 'ANY'}) {
    print('\nReceived remote message of type $type, id: ${message.messageId}');
    print('data: ${message.data}');
    if (message.notification != null) {
      print("notification: ${message.notification}\n");
    }
  }

  // gets initial message from background
  Future<RemoteMessage> getInitialMessage() async {
    RemoteMessage initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _log(initial, type: 'REMOTE INITIAL');
    return initial;
  }

  Future<void> sendToken() async {
    return ApiClient.saveFCMToken(_fcmToken);
  }
}
