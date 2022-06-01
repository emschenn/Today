import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/services/collect_image_service.dart';
import 'package:workmanager/workmanager.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/config/theme.dart';

import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/services/local_notification.dart';

import 'package:pichint/screens/splash_screen.dart';
import 'package:pichint/screens/add/add_screen.dart';
import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/screens/setting_screen.dart';

Future<void> messageHandler(RemoteMessage msg) async {
  print('receive message when app is in background');
  if (msg.data['action'] == 'COLLECT_IMAGES') {
    UserData? user = await collectImagesSetUp();
    CollectedImage collectedImage = await collectImagesFromLibrary(user);
    if (collectedImage.imgList!.isNotEmpty) {
      await sendCollectedImagesToServer(collectedImage, user!);
    }
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool result = false;
    UserData? user = await collectImagesSetUp();
    CollectedImage collectedImage = await collectImagesFromLibrary(user);
    if (collectedImage.imgList!.isNotEmpty) {
      result = await sendCollectedImagesToServer(collectedImage, user!);
    }
    print("Native called background task");
    return result;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  if (Platform.isIOS) {
    Workmanager().registerOneOffTask(
      "task-identifier",
      "collectImages",
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  } else {
    Workmanager().registerPeriodicTask(
      "task-identifier",
      "collectImages",
      frequency: const Duration(hours: 2),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
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

  @override
  void initState() {
    if (Platform.isAndroid) {
      LocalNotificationService.initialize();
    }
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
