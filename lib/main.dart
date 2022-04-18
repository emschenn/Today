// ignore_for_file: avoid_print
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pichint/services/api_service.dart';
import 'package:workmanager/workmanager.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/config/theme.dart';
import 'package:pichint/screens/splash_screen.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';

import 'package:pichint/screens/add/add_screen.dart';
import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/screens/setting_screen.dart';
import 'package:pichint/services/local_notification.dart';

Future<void> backgroundMessageHandler(RemoteMessage msg) async {
  print(msg.notification!.title);
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    print('work manager 🌟' + taskName);
    switch (taskName) {
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        break;
      case "calcNewPhotos":
        print('hello');
        ApiService().collectImages(inputData);
        print(
            "Replace this print statement with your code that should be executed in the background here");
        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  await Firebase.initializeApp();
  runApp(const MyApp());
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

  void initFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    LocalNotificationService.initialize(context);

    /// Handler when app is closed and user taps
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) {
        print('Received a notification: ${msg.notification!.title}');
      }
    });

    /// Handler when app is in foreground
    FirebaseMessaging.onMessage.listen((msg) {
      if (msg.notification != null) {
        print('Received a notification: ${msg.notification!.title}');
        LocalNotificationService.display(msg);
      }
    });

    /// Handler when app is in background but opened and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      print(msg.data['route']);
    });

    /// Handler when app is in background
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: basicTheme(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _storage.read(key: 'uid').then((value) async {
          UserData? user;
          await FirebaseService().getUserData(value).then((value) {
            _global.setUserData = value;
            user = value;
          });
          return user;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const LoginScreen();
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const SplashScreen();
          }
        },
      ),
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:background_fetch/background_fetch.dart';

// // [Android-only] This "Headless Task" is run when the Android app
// // is terminated with enableHeadless: true
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

// void main() {
//   // Enable integration testing with the Flutter Driver extension.
//   // See https://flutter.io/testing/ for more info.
//   runApp(new MyApp());

//   // Register to receive BackgroundFetch events after app is terminated.
//   // Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _enabled = true;
//   int _status = 0;
//   List<DateTime> _events = [];

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Configure BackgroundFetch.
//     int status = await BackgroundFetch.configure(
//         BackgroundFetchConfig(
//             minimumFetchInterval: 15,
//             stopOnTerminate: false,
//             enableHeadless: true,
//             requiresBatteryNotLow: false,
//             requiresCharging: false,
//             requiresStorageNotLow: false,
//             requiresDeviceIdle: false,
//             requiredNetworkType: NetworkType.NONE), (String taskId) async {
//       // <-- Event handler
//       // This is the fetch-event callback.
//       print("[BackgroundFetch] Event received $taskId");
//       setState(() {
//         _events.insert(0, new DateTime.now());
//       });
//       // IMPORTANT:  You must signal completion of your task or the OS can punish your app
//       // for taking too long in the background.
//       BackgroundFetch.finish(taskId);
//     }, (String taskId) async {
//       // <-- Task timeout handler.
//       // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
//       print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
//       BackgroundFetch.finish(taskId);
//     });
//     print('[BackgroundFetch] configure success: $status');
//     setState(() {
//       _status = status;
//     });

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//   }

//   void _onClickEnable(enabled) {
//     setState(() {
//       _enabled = enabled;
//     });
//     if (enabled) {
//       BackgroundFetch.start().then((int status) {
//         print('[BackgroundFetch] start success: $status');
//       }).catchError((e) {
//         print('[BackgroundFetch] start FAILURE: $e');
//       });
//     } else {
//       BackgroundFetch.stop().then((int status) {
//         print('[BackgroundFetch] stop success: $status');
//       });
//     }
//   }

//   void _onClickStatus() async {
//     int status = await BackgroundFetch.status;
//     print('[BackgroundFetch] status: $status');
//     setState(() {
//       _status = status;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//             title: const Text('BackgroundFetch Example',
//                 style: TextStyle(color: Colors.black)),
//             backgroundColor: Colors.amberAccent,
//             actions: <Widget>[
//               Switch(value: _enabled, onChanged: _onClickEnable),
//             ]),
//         body: Container(
//           color: Colors.white,
//           child: ListView.builder(
//               itemCount: _events.length,
//               itemBuilder: (BuildContext context, int index) {
//                 DateTime timestamp = _events[index];
//                 print(_events[index]);
//                 return InputDecorator(
//                     decoration: const InputDecoration(
//                         contentPadding:
//                             EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
//                         labelStyle: TextStyle(
//                             color: Colors.amberAccent, fontSize: 20.0),
//                         labelText: "[background fetch event]"),
//                     child: Text(timestamp.toString(),
//                         style: const TextStyle(
//                             color: Colors.white, fontSize: 16.0)));
//               }),
//         ),
//         bottomNavigationBar: BottomAppBar(
//             child: Row(children: <Widget>[
//           GestureDetector(onTap: _onClickStatus, child: Text('Status')),
//           Container(
//               child: Text("$_status"),
//               margin: const EdgeInsets.only(left: 20.0))
//         ])),
//       ),
//     );
//   }
// }
