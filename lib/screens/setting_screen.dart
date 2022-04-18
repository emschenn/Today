import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/widgets/custom_appbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late UserData user;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    user = GlobalService().getUserData;
    super.initState();
  }

  void logout() {
    _storage.delete(key: 'uid');
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 250),
          child: const LoginScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: '設定',
            action: TextButton(
                child: Text('完成',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            leading: TextButton(
                child: Text('取消',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    var data = <String, dynamic>{
                      'uid': user.uid,
                      'path':
                          '${user.group}/${user.isParent! ? 'parent' : 'child'}',
                      'timestamp': user.latestTimestamp,
                    };
                    ApiService().collectImages(data);
                  },
                  child: const Text("test test"),
                ),
                const Text('設定通知頻率',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    logout();
                  },
                  child: const Text("登出"),
                ),
              ],
            )));
  }
}
