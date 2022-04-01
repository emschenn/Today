import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';

class EditPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    void _deletePhoto() async {
      final writeSuccess =
          await FirebaseService().deletePhoto(user.group, photo);
      if (writeSuccess) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 250),
            child: const HomeScreen(),
          ),
        );
      }
    }

    void _savePhoto() async {
      final ByteData imageData = await NetworkAssetBundle(
              Uri.parse('${ApiService().baseUrl}/img/${photo.filename!}'))
          .load("");
      final Uint8List bytes = imageData.buffer.asUint8List();
      await PhotoManager.editor.saveImage(
        bytes,
        title: '${photo.timestamp!.toString()}.jpg',
      );
      closePanel();
    }

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (user.uid == photo.authorId)
            GestureDetector(
                onTap: () {
                  _deletePhoto();
                },
                child: Container(
                  width: size.width,
                  margin: const EdgeInsets.fromLTRB(24, 12, 24, 6),
                  padding: const EdgeInsets.all(12.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: Column(children: [
                    Text('刪除照片', style: Theme.of(context).textTheme.button)
                  ]),
                )),
          GestureDetector(
              onTap: () {
                _savePhoto();
              },
              child: Container(
                width: size.width,
                margin: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Column(children: [
                  Text('儲存照片', style: Theme.of(context).textTheme.button)
                ]),
              )),
        ]));
  }
}
