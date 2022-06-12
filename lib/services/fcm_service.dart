import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/add/add_screen.dart';
import 'package:pichint/screens/photo/photo_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/collect_image_service.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/services/local_notification.dart';

class FcmService {
  UserData? user = GlobalService().getUserData;

  void handleNotificationClick(context, RemoteMessage msg) async {
    var data = msg.data;
    await FirebaseAnalytics.instance.logEvent(
      name: "click_notification",
      parameters: {
        "notification_type": data['action'],
        "user_id": user!.uid,
      },
    );
    if (data['action'] == 'NUDGE_AI_NOTIFICATION' ||
        data['action'] == 'NUDGE_SCHEDULED_NOTIFICATION') {
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            duration: const Duration(milliseconds: 250),
            reverseDuration: const Duration(milliseconds: 250),
            child: const AddPhotoScreen(),
          ),
          (route) => route.isFirst);
    } else if (data['action'] == 'NEW_NOTIFICATION') {
      var photoData = PhotoData.fromJsonWithId(jsonDecode(data['payload']!));
      final snapshot = await FirebaseDatabase.instance
          .ref('groups/${user!.group}/photos/${photoData.pid}')
          .get();
      if (snapshot.exists) {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              duration: const Duration(milliseconds: 250),
              reverseDuration: const Duration(milliseconds: 250),
              child: PhotoScreen(photo: photoData),
            ),
            (route) => route.isFirst);
      }
    }
  }

  void updateMsgToken(messaging) async {
    String? token = await messaging.getToken();
    await FirebaseService().setUserMsgToken(user!.uid, token);

    messaging.onTokenRefresh.listen((newToken) {
      print("token refresh: " + newToken);
      FirebaseService().setUserMsgToken(user!.uid, newToken);
    });
  }

  void setUpFirebaseMessaging(context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    updateMsgToken(messaging);

    /// Handler when app is closed and user taps
    messaging.getInitialMessage().then((msg) {
      if (msg != null) {
        handleNotificationClick(context, msg);
      }
    });

    /// Handler when app is in background but opened and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((msg) async {
      print('app is in background but opened and user taps');
      handleNotificationClick(context, msg);
    });

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create an Android Notification Channel.
    //
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      print('Got a message whilst in the foreground!');
      if (Platform.isAndroid) {
        LocalNotificationService.display(msg);
      }
      if (msg.data['action'] == 'COLLECT_IMAGES') {
        CollectedImage collectedImage = await collectImagesFromLibrary(user);
        if (collectedImage.imgList!.isNotEmpty) {
          await sendCollectedImagesToServer(collectedImage, user!);
        }
      }
    });
  }
}
