import 'dart:typed_data';
import 'package:blurhash/blurhash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/home_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/widgets/custom_appbar.dart';
import 'package:pichint/widgets/custom_button.dart';
import 'package:pichint/config/icons.dart';

class AddDescScreen extends StatefulWidget {
  final Uint8List image;
  const AddDescScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<AddDescScreen> createState() => _AddDescScreenState();
}

class _AddDescScreenState extends State<AddDescScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TextEditingController _editorController;
  late ScrollController _scrollController;
  late UserData user;
  final _global = GlobalService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    user = _global.getUserData;
    _scrollController = ScrollController();
    _editorController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _editorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sharePhoto() async {
    var identity = user.isParent! ? 'parent' : 'child';
    var now = DateTime.now();
    var filename =
        '${user.group}_${identity}_${now.millisecondsSinceEpoch}.jpg';
    final uploadSuccess =
        await ApiService().uploadImage(widget.image, filename);
    if (uploadSuccess) {
      Uint8List pixels = widget.image.buffer.asUint8List();
      String blurHash = await BlurHash.encode(pixels, 4, 3);
      print(blurHash);
      PhotoData photo = PhotoData(
          date: now,
          description: _editorController.text,
          author: user.name,
          authorId: user.uid,
          timestamp: now.millisecondsSinceEpoch,
          path: 'images/$filename');
      final writeSuccess = await FirebaseService().addPhoto(user.group, photo);
      if (writeSuccess) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.topToBottom,
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 250),
            child: const HomeScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var contentWidth = size.width - 40;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: '分享照片',
            action: GestureDetector(
                onTap: () {
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
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          children: [
                            Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                height: contentWidth * 0.76,
                                width: contentWidth * 0.76,
                                color: Colors.grey[100],
                                child: Image.memory(widget.image)),
                            TextField(
                                controller: _editorController,
                                minLines: 2,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black45),
                                  ),
                                  hintText: "填寫圖片敘述",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                style: Theme.of(context).textTheme.bodyText1),
                            const SizedBox(
                              height: 20,
                            ),
                            // CustomButton(
                            //   color: Theme.of(context).primaryColor,
                            //   text: '確定分享',
                            //   textColor: Colors.white,
                            //   onClick: () {
                            //     _sharePhoto();
                            //   },
                            // ),
                          ],
                        ))))));
  }
}
