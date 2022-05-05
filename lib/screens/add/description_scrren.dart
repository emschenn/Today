import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/utils/show_dialog.dart';
import 'package:pichint/widgets/custom_appbar.dart';
import 'package:pichint/widgets/animated_dialog.dart';

class AddDescScreen extends StatefulWidget {
  final Uint8List image;
  final bool isFromRec;
  const AddDescScreen({Key? key, required this.image, required this.isFromRec})
      : super(key: key);

  @override
  State<AddDescScreen> createState() => _AddDescScreenState();
}

class _AddDescScreenState extends State<AddDescScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TextEditingController _editorController;
  late UserData user;
  bool _loading = false;
  final _global = GlobalService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    user = _global.getUserData!;
    _editorController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  void _sharePhoto() async {
    setState(() {
      _loading = true;
    });
    var identity =
        user.identity! == 'mom' || user.identity! == 'dad' ? 'parent' : 'child';
    var now = DateTime.now();
    var description = _editorController.text;
    var filename =
        '${user.group}_${identity}_${now.millisecondsSinceEpoch}.jpg';
    var image = MultipartFile.fromBytes(widget.image, filename: filename);
    final uploadSuccess =
        await ApiService().uploadImage(image, user, description);
    setState(() {
      _loading = false;
    });
    if (uploadSuccess) {
      await FirebaseAnalytics.instance.logEvent(
        name: "upload_photo",
        parameters: {
          "user_id": user.uid,
          "is_from_rec": widget.isFromRec,
          // "photo_id": photo.pid,
        },
      );
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.topToBottom,
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 250),
          child: const HomeScreen(),
        ),
      );
    } else {
      await showAlertDialog(
          context: context,
          title: "上傳失敗",
          content: "請確定手機是否正確連上網路後再試一次。若問題持續發生，請聯繫研究人員 💬",
          cancelText: "再試一次",
          cancelAction: () {
            Navigator.of(context).pop(false);
          },
          confirmText: "回到相簿",
          confirmAction: () {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.topToBottom,
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 250),
                child: const HomeScreen(),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var contentWidth = size.width - 40;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: false,
        appBar: CustomAppBar(
            title: '分享照片',
            centerTitle: true,
            action: GestureDetector(
                onTap: () {
                  if (_loading) return;
                  _sharePhoto();
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0))),
                    child: const Text('送出'))),
            leading: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: SafeArea(
            child: Stack(children: [
          GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Container(
                  color: Colors.white,
                  height: size.height,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            height: contentWidth * 0.3,
                            width: contentWidth * 0.3,
                            color: Colors.grey[100],
                            child: Hero(
                                tag: widget.image,
                                child: Image.memory(widget.image))),
                        Expanded(
                          flex: 1,
                          child: CupertinoTextField(
                              padding: const EdgeInsets.all(12),
                              cursorColor: Colors.black54,
                              controller: _editorController,
                              minLines: 4,
                              maxLines: null,
                              placeholder: "新增照片敘述 (選填)",
                              keyboardType: TextInputType.multiline,
                              style: Theme.of(context).textTheme.bodyText1),
                        ),
                      ]))),
          AnimatedDialog(
              isShow: _loading,
              backgroundColor: const Color.fromARGB(50, 0, 0, 0),
              child: const Center(
                  child: SpinKitThreeBounce(
                color: Colors.white,
                size: 30.0,
              ))),
        ])));
  }
}
