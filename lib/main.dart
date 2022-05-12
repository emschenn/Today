import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';

import 'package:pichint/config/theme.dart';

import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/services/local_notification.dart';
import 'package:pichint/services/api_service.dart';

import 'package:pichint/screens/splash_screen.dart';
import 'package:pichint/screens/photo/photo_screen.dart';
import 'package:pichint/screens/add/add_screen.dart';
import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/screens/setting_screen.dart';

Future<void> messageHandler(RemoteMessage msg) async {
  print('receive message when app is in background');
  if (msg.data['action'] == 'COLLECT_IMAGES') {
    ApiService().collectImages();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
    theme: basicTheme(),
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case '/home':
          return pageTransition(settings, const HomeScreen());
        case '/setting':
          return pageTransition(settings, const SettingScreen());
        case '/add':
          return pageTransition(settings, const AddPhotoScreen());
        default:
          return null;
      }
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _storage = const FlutterSecureStorage();
  final _global = GlobalService();
  UserData? user;

  void handleNotificationClick(RemoteMessage msg) async {
    var data = msg.data;
    await FirebaseAnalytics.instance.logEvent(
      name: "click_notification",
      parameters: {
        "notification_type": data['action'],
        "user_id": user!.uid,
      },
    );
    if (data['action'] == 'AI_NOTIFICATION') {
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

  void updateMsgToken(messaging) async {
    String? token = await messaging.getToken();
    await FirebaseService().setUserMsgToken(user!.uid, token);

    messaging.onTokenRefresh.listen((newToken) {
      print("token refresh: " + newToken);
      FirebaseService().setUserMsgToken(user!.uid, newToken);
    });
  }

  void setUpFirebaseMessaging() async {
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
        handleNotificationClick(msg);
      }
    });

    /// Handler when app is in background but opened and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((msg) async {
      print('app is in background but opened and user taps');
      handleNotificationClick(msg);
    });

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
        ApiService().collectImages();
      }
    });

    /// Handler when app is in background
    FirebaseMessaging.onBackgroundMessage(messageHandler);
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      LocalNotificationService.initialize();
    }
    setUpFirebaseMessaging();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _storage.read(key: 'uid').then((value) async {
        UserData? user;
        await FirebaseService().getUserData(value).then((value) {
          _global.setUserData = value;
          user = value;
        });
        return user;
      }),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasError) {
          child = const LoginScreen();
        } else if (snapshot.hasData) {
          child = const HomeScreen();
        } else {
          child = const SplashScreen();
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

PageTransition pageTransition(RouteSettings settings, Widget child) {
  return PageTransition(
    child: child,
    type: PageTransitionType.bottomToTop,
    settings: settings,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 250),
  );
}
