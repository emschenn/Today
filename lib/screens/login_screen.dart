import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/utils/show_dialog.dart';
import 'package:pichint/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final _firebaseService = FirebaseService();
  String _errorMsg = '';
  bool _isLoading = false;

  Future login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _accountController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;
      await _storage
          .write(
        key: 'uid',
        value: uid,
      )
          .then((value) async {
        String? token = await FirebaseMessaging.instance.getToken();
        await _firebaseService.setUserMsgToken(uid, token);
        _firebaseService.getUserData(uid).then((user) async {
          await FirebaseAnalytics.instance.setUserProperty(
            name: 'identity',
            value: user.identity == 'mom' || user.identity == 'dad'
                ? 'parent'
                : 'child',
          );
          await FirebaseAnalytics.instance.logEvent(
            name: "login",
            parameters: {
              "timestamp": DateTime.now().toString(),
              "user_id": uid,
            },
          );
          GlobalService().setUserData = user;
          setState(() {
            _isLoading = false;
          });
          print(GlobalService().getUserData!.uid);
          Navigator.pushReplacementNamed(context, '/home');
        });
      });
    } on FirebaseAuthException catch (e) {
      _accountController.clear();
      _passwordController.clear();
      setState(() {
        _errorMsg = e.code.replaceAll('-', ' ');
        _isLoading = false;
      });
      if (e.code == 'network-request-failed') {
        await showAlertDialog(
            context: context,
            title: "發生錯誤",
            content: "請確定手機是否正確連上網路後再試一次。若問題持續發生，請聯繫研究人員 💬",
            confirmText: "確定",
            confirmAction: () {
              Navigator.of(context).pop(false);
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var borderRadius = const BorderRadius.all(Radius.circular(8.0));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: SafeArea(
              child: Center(
                  child: Column(children: [
        Image.asset('assets/login.png', height: size.height * 0.5),
        SizedBox(
          height: size.height * 0.4,
          width: size.width * 0.65,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(_errorMsg,
                    style: TextStyle(color: Theme.of(context).errorColor)),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: _accountController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      hintText: '請輸入帳號 (您的信箱)',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black45),
                        borderRadius: borderRadius,
                      ),
                      hintStyle: const TextStyle(color: Colors.black45),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      border: const OutlineInputBorder(),
                      hintText: '請輸入密碼',
                      hintStyle: const TextStyle(color: Colors.black45),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black45),
                        borderRadius: borderRadius,
                      ),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(
                  height: 40,
                ),
                _isLoading
                    ? TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                          textStyle: Theme.of(context).textTheme.button,
                          minimumSize: const Size(120, 42),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                        ),
                        onPressed: () {},
                        child: const SizedBox(
                            width: 120,
                            child: SpinKitThreeBounce(
                              color: Colors.white,
                              size: 20.0,
                            )))
                    : CustomButton(
                        color: Theme.of(context).primaryColor,
                        text: '登入',
                        textColor: Colors.white,
                        onClick: login,
                      )
              ])),
        )
      ])))),
    );
  }
}
