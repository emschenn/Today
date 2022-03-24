import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';

import '../config/icons.dart';
import '../widgets/custom_button.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with TickerProviderStateMixin {
  late TextEditingController _editorController;
  late ScrollController _scrollController;
  late AnimationController _focusAnimationController;
  late Animation<double> _sizedBoxAnimation;
  late UserData user;
  List<dynamic> _photoList = [];
  List<dynamic> _placeholderList = [];
  AssetEntity? selectedPhoto;
  Uint8List? selectedPlaceholder;
  final _global = GlobalService();

  @override
  void initState() {
    _fetchNewMedia();
    user = _global.getUserData;
    _scrollController = ScrollController();
    _editorController = TextEditingController();
    _focusAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _sizedBoxAnimation = Tween<double>(begin: 18, end: 120).animate(
        CurvedAnimation(
            parent: _focusAnimationController, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    _editorController.dispose();
    _scrollController.dispose();
    _focusAnimationController.dispose();
    super.dispose();
  }

  void sharePhoto() async {
    dynamic img;
    await selectedPhoto!.originBytes.then((value) {
      img = value;
    });
    var identity = user.isParent! ? 'parent' : 'child';
    var now = DateTime.now();
    var filename = '${user.group}_${identity}_$now.jpg';
    final uploadSuccess = await ApiService().uploadImage(img, filename);
    if (uploadSuccess) {
      PhotoData photo = PhotoData(
          date: now,
          description: _editorController.text,
          author: user.name,
          path: 'images/$filename');
      final writeSuccess = await FirebaseService().addPhoto(user.group, photo);
      if (writeSuccess) {}
    }
    // print(uploadResponse);
  }

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 4);
      var imgList = [];
      for (var img in media) {
        await img.thumbDataWithSize(600, 600).then((value) {
          imgList.add(value);
        });
      }
      setState(() {
        _photoList = media;
        _placeholderList = imgList;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  void setPhoto(img) {
    setState(() {
      selectedPhoto = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var contentWidth = size.width - 40;

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
                margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        height: contentWidth * 0.76,
                        width: contentWidth * 0.76,
                        color:
                            Colors.grey[100], //.of(context).primaryColorLight,
                        child: selectedPhoto == null
                            ? const Center(child: Text('從下方選擇欲上傳的照片'))
                            : Image.memory(selectedPlaceholder!)),
                    Row(
                        children: _photoList.isEmpty
                            ? [
                                Container(
                                  height: contentWidth / 4,
                                )
                              ]
                            : [
                                for (int index = 0; index < 4; index++)
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedPhoto = _photoList[index];
                                          selectedPlaceholder =
                                              _placeholderList[index];
                                        });
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(2),
                                          height: contentWidth / 4,
                                          width: contentWidth / 4,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: MemoryImage(
                                                    _placeholderList[index])),
                                          )))
                              ]),
                    Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: const [
                                Text(
                                  '隨機推薦',
                                  style: TextStyle(fontSize: 13),
                                ),
                                // SizedBox(width: 4),
                                // Icon(CustomIcon.picture, size: 14),
                              ],
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: const [
                                Icon(CustomIcon.plus, size: 14),
                                SizedBox(width: 3),
                                Text(
                                  '選擇其他照片上傳',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 0),
                      child: Focus(
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              _scrollController.animateTo(
                                180,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                              _focusAnimationController.forward();
                            } else {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                              );
                              _focusAnimationController.reverse();
                            }
                          },
                          child: TextField(
                            controller: _editorController,
                            minLines: 2,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              hintText: "填寫圖片敘述",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          )),
                    ),
                    AnimatedBuilder(
                        animation: _focusAnimationController,
                        builder: (BuildContext context, _) {
                          return SizedBox(height: _sizedBoxAnimation.value);
                        }),
                    CustomButton(
                      color: Theme.of(context).primaryColor,
                      text: '確定分享',
                      textColor: Colors.white,
                      onClick: () {
                        sharePhoto();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ))));
  }
}
