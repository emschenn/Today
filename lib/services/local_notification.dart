import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification_icon'));

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    if (message.notification == null) return;
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      AndroidNotificationDetails androidDetails;
      if (message.data['image'] != null) {
        final String imgPath =
            await _downloadAndSaveFile(message.data['image'], 'bigPicture.jpg');
        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(FilePathAndroidBitmap(imgPath),
                contentTitle: message.notification!.title,
                htmlFormatContentTitle: true,
                summaryText: message.notification!.body,
                htmlFormatSummaryText: true);
        androidDetails = AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            color: const Color(0xFFCB5B3F),
            largeIcon: FilePathAndroidBitmap(imgPath),
            styleInformation: bigPictureStyleInformation);
      } else {
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
      }
      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: androidDetails,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}

// import 'package:awesome_notifications/awesome_notifications.dart';

// class LocalNotificationService {
//   static void initialize() {
//     AwesomeNotifications().requestPermissionToSendNotifications();
//     AwesomeNotifications()
//         .initialize('resource://drawable/ic_notification_icon', [
//       NotificationChannel(
//           channelKey: 'notify_with_badge',
//           channelName: 'Basic notifications with badge',
//           channelDescription:
//               'Notification channel for notification with badge',
//           defaultColor:
//               const Color(0xFFCB5B3F), //Theme.of(context).primaryColor,
//           ledColor: Colors.white,
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//           playSound: true,
//           enableLights: true,
//           enableVibration: true),
//       NotificationChannel(
//           channelKey: 'notify_without_badge',
//           channelName: 'Basic notifications without badge',
//           channelDescription:
//               'Notification channel for notification without badge',
//           defaultColor:
//               const Color(0xFFCB5B3F), //Theme.of(context).primaryColor,
//           ledColor: Colors.white,
//           importance: NotificationImportance.High,
//           channelShowBadge: false,
//           playSound: true,
//           enableLights: true,
//           enableVibration: true)
//     ]);
//   }

//   static void display(bool withBadge, RemoteMessage msg) async {
//     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     var p = {};
//     if (msg.data['action'] == 'NEW_NOTIFICATION') {
//       print(msg.data['payload']);
//       // PhotoData.fromJson(jsonDecode(msg.data['payload']));
//     }
//     AwesomeNotifications().createNotification(
//         content: NotificationContent(
//             id: id,
//             channelKey:
//                 withBadge ? 'notify_with_badge' : 'notify_without_badge',
//             title: msg.data['title'],
//             body: msg.data['body'],
//             wakeUpScreen: true,
//             // bigPicture: msg.data['image'],
//             notificationLayout: NotificationLayout.BigPicture,
//             largeIcon: msg.data['image'],
//             payload: {
//           "action": msg.data['action'],
//           "photoData": msg.data['action'] == 'NEW_NOTIFICATION'
//               ? msg.data['payload']
//               : ''
//         }));
//   }
// }
