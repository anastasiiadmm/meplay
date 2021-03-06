import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api_client.dart';


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
  _logMessage(message, type: 'BACKGROUND TERM');
}


class NotificationHelper {
  static NotificationHelper _instance;
  FlutterLocalNotificationsPlugin _flnp;
  AndroidNotificationChannel _channel;

  NotificationHelper._();

  static get instance async {
    if (_instance == null) {
      _instance = NotificationHelper._();
      await _instance.init();
    }
    return _instance;
  }

  Future<void> init() async {
    await _initFirebase();
    await _initLocal();
    await _initChannel();
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessage.listen(_fgMessageHandler);
    FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_remoteMessageOpen);
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
      'Напоминания о программах и пуш-уведомления MePlay',  // description
      importance: Importance.max,
    );
    _flnp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> sendToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String token = await messaging.getToken();
    await ApiClient.saveFirebaseToken(token);
    messaging.onTokenRefresh.listen(ApiClient.saveFirebaseToken);
  }

  // Handles local messages received while app in foreground
  Future<void> _localMsgHandler(int id, String title,
      String body, String payload) async {

  }

  // Handles app opening when local notification tapped
  Future<void> _localMsgOpen(String payload) async {

  }

  // Handles fb messages received while app in foreground
  Future<void> _fgMessageHandler(RemoteMessage message) async {
    _logMessage(message, type: 'FOREGROUND');

    if (message.notification != null) {
      _flnp.show(
        message.hashCode,
        message.notification.title,
        message.notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            _channel.description,
            icon: message.notification.android?.smallIcon,
          ),
        ),
      );
    }
  }

  // Handles app opening when remote message tapped
  Future<void> _remoteMessageOpen(RemoteMessage message) async {
    _logMessage(message, type: 'BACKGROUND');


  }

  // Handles app opening from terminated state when remote message tapped
  Future<RemoteMessage> getInitialMessage() async {
    RemoteMessage message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null)
      _logMessage(message, type: 'INITIAL');
    return message;
  }
}
