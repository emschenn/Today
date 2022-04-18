import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:pichint/config/icons.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';
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
      setState(() {
        _isLoading = true;
      });
      final writeSuccess =
          await ApiService().deleteImage(widget.user.group, widget.photo);
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = true;
      });
      final ByteData imageData = await NetworkAssetBundle(Uri.parse(
              '${ApiService().baseUrl}/img/${widget.photo.filename!}'))
          .load("");
      final Uint8List bytes = imageData.buffer.asUint8List();
      await PhotoManager.editor.saveImage(
        bytes,
        title: '${widget.photo.timestamp!.toString()}.jpg',
      );
      setState(() {
        _isLoading = false;
      });
      widget.closePanel();
    }

    return SafeArea(
        child: Stack(children: [
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (widget.user.uid == widget.photo.authorId)
          GestureDetector(
              onTap: () {
                _deletePhoto();
              },
              child: Container(
                width: size.width,
                margin: const EdgeInsets.fromLTRB(24, 12, 24, 6),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
              child: Column(children: [
                Text('儲存照片', style: Theme.of(context).textTheme.button)
              ]),
            )),
      ]),
      // AnimatedDialog(
      //     isShow: _isSaved,
      //     backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      //     child: Center(
      //         child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //           Icon(CustomIcon.download,
      //               size: 40, color: Colors.white.withOpacity(0.8)),
      //           const SizedBox(height: 16),
      //           Text('已儲存',
      //               style: Theme.of(context)
      //                   .textTheme
      //                   .bodyText1!
      //                   .merge(TextStyle(color: Colors.white.withOpacity(0.8))))
      //         ]))),
      AnimatedDialog(
          isShow: _isLoading,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
          child: Center(
              child: SpinKitThreeBounce(
            color: Colors.white.withOpacity(0.8),
            size: 30.0,
          )))
    ]));
  }
}
