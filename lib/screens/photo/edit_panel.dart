import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/utils/show_dialog.dart';
import 'package:pichint/widgets/animated_dialog.dart';

class EditPanel extends StatefulWidget {
  final PhotoData photo;
  final UserData user;
  final Function closePanel;
  const EditPanel(
      {Key? key,
      required this.photo,
      required this.user,
      required this.closePanel})
      : super(key: key);

  @override
  State<EditPanel> createState() => _EditPanelState();
}

class _EditPanelState extends State<EditPanel> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var borderRadius = const BorderRadius.all(Radius.circular(8.0));

    void _deletePhoto() async {
      widget.closePanel();

      await showAlertDialog(
          context: context,
          title: "確定刪除照片？",
          content: "照片經刪除後將無法復原",
          cancelText: "取消",
          cancelAction: () {
            Navigator.of(context).pop(false);
          },
          confirmText: "刪除",
          confirmAction: () async {
            final writeSuccess = await ApiService()
                .deleteImage(widget.user.group, widget.photo, widget.user.uid);
            if (writeSuccess) {
              await FirebaseAnalytics.instance.logEvent(
                name: "delete_photo",
                parameters: {
                  "user_id": widget.user.uid,
                  "photo_id": widget.photo.pid,
                },
              );
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 200),
                    reverseDuration: const Duration(milliseconds: 250),
                    child: const HomeScreen(),
                  ));
            } else {
              await showAlertDialog(
                  context: context,
                  title: "發生錯誤",
                  content: "請確定手機是否正確連上網路後再試一次。若問題持續發生，請聯繫研究人員 💬",
                  confirmText: "確定",
                  confirmAction: () {
                    Navigator.of(context).pop(false);
                  });
            }
          });
    }

    void _savePhoto() async {
      setState(() {
        _isLoading = true;
      });
      final ByteData imageData = await NetworkAssetBundle(Uri.parse(
              '${ApiService().baseUrl}/img/${widget.photo.filename!}'))
          .load("");
      final Uint8List bytes = imageData.buffer.asUint8List();
      await PhotoManager.editor.saveImage(
        bytes,
        title: widget.photo.filename!.toString(),
      );
      await FirebaseAnalytics.instance.logEvent(
        name: "save_photo",
        parameters: {
          "user_id": widget.user.uid,
          "photo_id": widget.photo.pid,
        },
      );
      setState(() {
        _isLoading = false;
      });
      widget.closePanel();
    }

    void _editPhoto() async {
      widget.closePanel();

      TextEditingController _editController = TextEditingController()
        ..text = widget.photo.description ?? '';

      await showAlertDialog(
          context: context,
          title: "編輯相片敘述",
          isCustomContent: true,
          contentWidget: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: CupertinoTextField(
                  cursorColor: Colors.black54,
                  padding: const EdgeInsets.all(12),
                  controller: _editController,
                  minLines: 4,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: Theme.of(context).textTheme.bodyText1)),
          cancelText: "取消",
          cancelAction: () {
            Navigator.of(context).pop(false);
          },
          confirmText: "送出",
          confirmAction: () async {
            var desc = _editController.text;
            await FirebaseService().updatePhotoDescription(
                widget.user.group, widget.photo.pid, desc);
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 250),
                child: const HomeScreen(),
              ),
            );
          });
    }

    return SafeArea(
        child: Stack(children: [
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (widget.user.uid == widget.photo.authorId) ...[
          Container(
              margin: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
              child: Column(children: [
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _editPhoto();
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        Text('編輯照片敘述',
                            style: Theme.of(context).textTheme.button)
                      ]),
                    )),
                const Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.black45,
                ),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _deletePhoto();
                    },
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        Text('刪除照片', style: Theme.of(context).textTheme.button)
                      ]),
                    )),
              ])),
        ],
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _savePhoto();
            },
            child: Container(
              width: size.width,
              margin: const EdgeInsets.fromLTRB(24, 6, 24, 24),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
              child: Column(children: [
                Text('儲存照片', style: Theme.of(context).textTheme.button)
              ]),
            )),
      ]),
      AnimatedDialog(
          isShow: _isLoading,
          backgroundColor: const Color.fromARGB(50, 0, 0, 0),
          child: const Center(
              child: SpinKitThreeBounce(
            color: Colors.white,
            size: 30.0,
          )))
    ]));
  }
}
