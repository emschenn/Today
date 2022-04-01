import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification_icon'),
        iOS: IOSInitializationSettings());

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'notify',
            'notify channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: IOSNotificationDetails());

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  static void show(String title, String body) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'notify',
            'notify channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: IOSNotificationDetails());

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
