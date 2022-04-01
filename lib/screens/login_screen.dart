import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
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
  final _global = GlobalService();
  String _errorMsg = '';

  Future login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _accountController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _storage
          .write(
        key: 'uid',
        value: userCredential.user!.uid,
      )
          .then((value) {
        FirebaseService().getUserData(userCredential.user!.uid).then((user) {
          _global.setUserData = user;
          Navigator.pushReplacementNamed(context, '/home');
        });
      });
    } on FirebaseAuthException catch (e) {
      _accountController.clear();
      _passwordController.clear();
      setState(() {
        _errorMsg = e.code.replaceAll('-', ' ');
      });
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Center(
              child: Column(children: [
        Image.asset('assets/main.jpg', height: size.height * 0.5),
        SizedBox(
          height: size.height * 0.45,
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
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      hintText: '請輸入帳號（您的信箱）',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      hintStyle: TextStyle(color: Colors.black45),
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
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      hintText: '請輸入密碼',
                      hintStyle: TextStyle(color: Colors.black45),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(
                  height: 40,
                ),
                CustomButton(
                  color: Theme.of(context).primaryColor,
                  text: '登入',
                  textColor: Colors.white,
                  onClick: login,
                )
              ])),
        )
      ]))),
    );
  }
}
