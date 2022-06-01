import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/screens/login_screen.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/utils/show_dialog.dart';
import 'package:pichint/widgets/custom_appbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late UserData user;
  final _storage = const FlutterSecureStorage();
  late TextEditingController _displayNameController;
  late int notifyWhenViewed;
  late bool enableViewedNotify;
  bool _isLoading = false;

  Map<int, String> viewCountNotifySetting = {
    0: '永遠不要',
    3: '3 次',
    5: '5 次',
    10: '10 次',
  };

  Map<bool, String> viewedNotifySetting = {
    true: '開啟',
    false: '關閉',
  };

  @override
  void initState() {
    user = GlobalService().getUserData!;
    _displayNameController = TextEditingController()..text = user.name!;
    notifyWhenViewed = user.notifyWhenViewCountsEqual!;
    enableViewedNotify = user.enableViewedNotify ?? false;
    super.initState();
  }

  void _logout() async {
    await showAlertDialog(
        context: context,
        title: "確定要登出嗎？",
        content: "登出後，需重新用帳號密碼登入",
        cancelText: "取消",
        cancelAction: () {
          Navigator.of(context).pop(false);
        },
        confirmText: "登出",
        confirmAction: () async {
          _storage.delete(key: 'uid');
          await FirebaseAnalytics.instance.logEvent(
            name: "logout",
            parameters: {
              "timestamp": DateTime.now().toString(),
              "user_id": user.uid,
            },
          );
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 250),
                child: const LoginScreen(),
              ),
              (Route<dynamic> route) => false);
        });
  }

  void _done() async {
    var _firebaseService = FirebaseService();
    print(user.enableViewedNotify);
    if ((_displayNameController.text == user.name ||
            _displayNameController.text.isEmpty) &&
        (notifyWhenViewed == user.notifyWhenViewCountsEqual!) &&
        enableViewedNotify == user.enableViewedNotify!) {
      Navigator.pop(context);
      return;
    }
    if (notifyWhenViewed != user.notifyWhenViewCountsEqual!) {
      await FirebaseAnalytics.instance.logEvent(
        name: "edit_view_count_notify",
        parameters: {
          "update_data": notifyWhenViewed,
          "user_id": user.uid,
        },
      );
    }
    if (enableViewedNotify != user.enableViewedNotify!) {
      await FirebaseAnalytics.instance.logEvent(
        name: "edit_viewed_notify",
        parameters: {
          "update_data": enableViewedNotify,
          "user_id": user.uid,
        },
      );
    }
    setState(() {
      _isLoading = true;
    });
    await _firebaseService.updateSetting(user.uid, _displayNameController.text,
        notifyWhenViewed, enableViewedNotify);
    GlobalService().setUserData = await _firebaseService.getUserData(user.uid);
    setState(() {
      _isLoading = false;
    });
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 250),
        child: const HomeScreen(),
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .copyWith(boldText: false),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
                title: '設定',
                centerTitle: true,
                action: _isLoading
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const SpinKitThreeBounce(
                          color: Colors.black54,
                          size: 14.0,
                        ))
                    : TextButton(
                        style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent)),
                        child: Text('完成',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark)),
                        onPressed: () {
                          _done();
                        }),
                leading: TextButton(
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent)),
                    child: Text('取消',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            body: SafeArea(
                child: Stack(alignment: Alignment.topCenter, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/setting.png',
                    height: 240,
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 8,
                                    child: Text('顯示名稱',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2)),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: _displayNameController,
                                      autocorrect: false,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 6),
                                        isDense: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black12),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black12),
                                        ),
                                      ),
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                )
                              ],
                            ),
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 8,
                                        child: Text('當對方瀏覽過照片時通知我',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2)),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: Container(
                                          height: 1,
                                          color: Colors.black12,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        elevation: 1,
                                        iconSize: 0.0,
                                        value: enableViewedNotify,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        items: List.generate(
                                            viewedNotifySetting.length,
                                            (index) {
                                          return DropdownMenuItem(
                                            value: viewedNotifySetting.keys
                                                .toList()[index],
                                            child: Center(
                                                child: Text(
                                              viewedNotifySetting.values
                                                  .toList()[index],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            )),
                                          );
                                        }),
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            enableViewedNotify = newValue!;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                )),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 8,
                                    child: Text('當對方瀏覽超過幾次時通知我',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2)),
                                Expanded(
                                  flex: 3,
                                  child: DropdownButton(
                                    isExpanded: true,
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black12,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    elevation: 1,
                                    iconSize: 0.0,
                                    value: notifyWhenViewed,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: List.generate(
                                        viewCountNotifySetting.length, (index) {
                                      return DropdownMenuItem(
                                        value: viewCountNotifySetting.keys
                                            .toList()[index],
                                        child: Center(
                                            child: Text(
                                          viewCountNotifySetting.values
                                              .toList()[index],
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        )),
                                      );
                                    }),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        notifyWhenViewed = newValue!;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ]))
                ],
              ),
              Positioned(
                  bottom: 32.0,
                  child: OutlinedButton(
                    onPressed: () {
                      _logout();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 42),
                      backgroundColor: Colors.white,
                      textStyle: Theme.of(context).textTheme.button,
                      primary: Colors.black54,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                    ),
                    child: const Text("登出"),
                  ))
            ]))));
  }
}
