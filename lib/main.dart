// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/models/user_model.dart';

import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/screens/home_screen.dart';

import 'package:pichint/config/theme.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();
  final _storage = const FlutterSecureStorage();
  final _global = GlobalService();
  UserData? user;

  @override
  void initState() {
    getUserDate();
    super.initState();
  }

  void getUserDate() {
    _storage.read(key: 'uid').then((value) async {
      await FirebaseService().getUserData(value).then((value) {
        _global.setUserData = value;
        setState(() {
          user = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: basicTheme(),
      home: FutureBuilder(
        future: _firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return user == null ? const LoginScreen() : const HomeScreen();
          } else {
            return const Text('loading');
          }
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return pageTransition(settings, const HomeScreen());
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
    type: PageTransitionType.fade,
    settings: settings,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 250),
  );
}
