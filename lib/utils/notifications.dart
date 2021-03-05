import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api_client.dart';


// doc says it should be top level function
Future<void> _bgMessageHandler(RemoteMessage message) async {
  print('\nbg: ${message.messageId}');
  print('d: ${message.data}');
  if (message.notification != null) {
    print("nf: ${message.notification}");
  }
}


class FirebaseHelper {
  static bool _ready = false;

  static Future<void> init() async {
    if (!_ready)
      await Firebase.initializeApp();
    _ready = true;
  }

  static Future<void> sendToken() async {
    init();
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String token = await messaging.getToken();
    await ApiClient.saveFirebaseToken(token);
    messaging.onTokenRefresh.listen(ApiClient.saveFirebaseToken);
  }

  static Future<void> receiveMessages() async {
    init();
    FirebaseMessaging.onMessage.listen(_fgMessageHandler);
    FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_messageOpenHandler);
    _checkForInitialMessage();
  }

  static Future<void> _fgMessageHandler(RemoteMessage message) async {
    print('\nfg: ${message.messageId}');
    print('d: ${message.data}');
    if (message.notification != null) {
      print("nf: ${message.notification}");
    }

    // https://firebase.flutter.dev/docs/messaging/notifications/
    // https://pub.dev/packages/flutter_local_notifications

    // flutterLocalNotificationsPlugin.show(
    //     notification.hashCode,
    //     notification.title,
    //     notification.body,
    //     NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         channel.id,
    //         channel.name,
    //         channel.description,
    //         icon: android?.smallIcon,
    //         // other properties...
    //       ),
    //     ));
  }

  static Future<void> _messageOpenHandler(RemoteMessage message) async {
    // this should open specific screen
    print('\no: ${message.messageId}');
    print('d: ${message.data}');
    if (message.notification != null) {
      print("nf: ${message.notification}");
    }


  }

  static Future<void> _checkForInitialMessage() async {
    // in case opened from terminated
    RemoteMessage message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      print('\nt: ${message.messageId}');
      print('d: ${message.data}');
      if (message.notification != null) {
        print("nf: ${message.notification}");
      }
    }
  }
}

