import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/add/description_scrren.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/widgets/custom_appbar.dart';
import 'package:pichint/widgets/custom_button.dart';
import 'package:pichint/config/icons.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({Key? key}) : super(key: key);

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ImagePicker _imgPicker = ImagePicker();
  late TextEditingController _editorController;
  late ScrollController _scrollController;
  late AnimationController _focusAnimationController;
  late UserData user;
  List<dynamic> _photoList = [];
  Uint8List? selectedImage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _fetchNewMedia();
    user = GlobalService().getUserData;
    _scrollController = ScrollController();
    _editorController = TextEditingController();
    _focusAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _editorController.dispose();
    _scrollController.dispose();
    _focusAnimationController.dispose();
    super.dispose();
  }

  void _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 6);
      var imgList = [];
      for (var img in media) {
        await img.originBytes.then((value) {
          imgList.add(value);
        });
      }
      setState(() {
        _photoList = imgList;
      });
    } else {
      // if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  void selectedImageFormGallery() async {
    final XFile? file = await _imgPicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final Uint8List byteData = await file.readAsBytes();
      setState(() {
        selectedImage = byteData;
      });
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
            action: selectedImage != null
                ? TextButton(
                    child: Text('下一步',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 200),
                          reverseDuration: const Duration(milliseconds: 250),
                          child: AddDescScreen(image: selectedImage!),
                        ),
                      );
                    })
                : Container(),
            leading: TextButton(
                child: Text('取消',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: SafeArea(
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
                            child: selectedImage == null
                                ? Center(
                                    child: Text('從下方選擇欲分享的照片',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1))
                                : Image.memory(selectedImage!)),
                        _photoList.isEmpty
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 50.0,
                              )
                            : GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                ),
                                children: [
                                  for (int index = 0;
                                      index < _photoList.length;
                                      index++)
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedImage = _photoList[index];
                                          });
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: MemoryImage(
                                                        _photoList[index])))))
                                ],
                              ),
                        Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    child: Text(
                                      '清除',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .merge(const TextStyle(fontSize: 13)),
                                    )),
                                GestureDetector(
                                    onTap: () {
                                      selectedImageFormGallery();
                                    },
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        const Icon(CustomIcon.plus, size: 12),
                                        const SizedBox(width: 3),
                                        Text(
                                          '選擇其他照片上傳',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .merge(const TextStyle(
                                                  fontSize: 13)),
                                        ),
                                      ],
                                    )),
                              ],
                            )),
                        // Container(
                        //   margin: const EdgeInsets.symmetric(
                        //       vertical: 12, horizontal: 0),
                        //   child: Focus(
                        //       onFocusChange: (hasFocus) {
                        //         if (hasFocus) {
                        //           _scrollController.animateTo(
                        //             180,
                        //             duration:
                        //                 const Duration(milliseconds: 500),
                        //             curve: Curves.easeIn,
                        //           );
                        //           _focusAnimationController.forward();
                        //         } else {
                        //           _scrollController.animateTo(
                        //             0,
                        //             duration:
                        //                 const Duration(milliseconds: 500),
                        //             curve: Curves.fastOutSlowIn,
                        //           );
                        //           _focusAnimationController.reverse();
                        //         }
                        //       },
                        //       child: TextField(
                        //           controller: _editorController,
                        //           minLines: 2,
                        //           decoration: InputDecoration(
                        //             enabledBorder: const OutlineInputBorder(
                        //               borderSide:
                        //                   BorderSide(color: Colors.black26),
                        //             ),
                        //             focusedBorder: const OutlineInputBorder(
                        //               borderSide:
                        //                   BorderSide(color: Colors.black45),
                        //             ),
                        //             hintText: "填寫圖片敘述",
                        //             hintStyle:
                        //                 TextStyle(color: Colors.grey[400]),
                        //           ),
                        //           keyboardType: TextInputType.multiline,
                        //           maxLines: null,
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .bodyText1)),
                        // ),
                        // AnimatedBuilder(
                        //     animation: _focusAnimationController,
                        //     builder: (BuildContext context, _) {
                        //       return SizedBox(
                        //           height: _sizedBoxAnimation.value);
                        //     }),

                        // CustomButton(
                        //   color: Theme.of(context).primaryColor,
                        //   text: '確定分享',
                        //   textColor: Colors.white,
                        //   onClick: () {
                        //     _sharePhoto();
                        //   },
                        // ),
                        const SizedBox(height: 24),
                      ],
                    )))));
  }
}
