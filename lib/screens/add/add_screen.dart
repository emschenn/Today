import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  List<dynamic>? _photoList;
  Uint8List? selectedImage;
  bool loadingSelectedImage = false;
  bool showRec = false;
  bool selectFromRec = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    user = GlobalService().getUserData!;
    _fetchNewMedia();
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
    var result = await ApiService().getRecommendedImage(user.uid);
    if (result != null) {
      var imgList = [];
      for (var img in result.images) {
        imgList.add(base64.decoder.convert(img));
      }
      if (imgList.isEmpty) {
        _fetchMediaFromLibrary();
      } else {
        setState(() {
          showRec = true;
          _photoList = imgList;
        });
      }
    } else {
      _fetchMediaFromLibrary();
    }
  }

  void _fetchMediaFromLibrary() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 6);
      var imgList = [];
      for (var img in media) {
        await img
            .thumbDataWithSize(600, 600 * img.height ~/ img.width)
            .then((value) {
          imgList.add(value);
        });
      }
      setState(() {
        showRec = false;
        _photoList = imgList;
      });
    } else {}
  }

  void _selectedImageFormGallery() async {
    var originalImage = selectedImage;
    setState(() {
      selectedImage = null;
      loadingSelectedImage = true;
    });
    final XFile? file = await _imgPicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final Uint8List? byteData = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 25,
      );
      setState(() {
        loadingSelectedImage = false;
        selectedImage = byteData;
        selectFromRec = false;
      });
    } else {
      setState(() {
        loadingSelectedImage = false;
        selectedImage = originalImage;
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
            centerTitle: true,
            action: selectedImage != null
                ? TextButton(
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent)),
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
                          child: AddDescScreen(
                              image: selectedImage!, isFromRec: selectFromRec),
                        ),
                      );
                    })
                : Container(),
            leading: TextButton(
                style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(Colors.transparent)),
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
                                ? loadingSelectedImage
                                    ? const SpinKitThreeBounce(
                                        color: Colors.black45,
                                        size: 30.0,
                                      )
                                    : Center(
                                        child: Text('從下方選擇欲分享的照片',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1))
                                : Hero(
                                    tag: selectedImage!,
                                    child: Image.memory(
                                      selectedImage!,
                                      frameBuilder: (context, child, frame,
                                          wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded) {
                                          return child;
                                        }
                                        return frame != null
                                            ? child
                                            : const SpinKitThreeBounce(
                                                color: Colors.black45,
                                                size: 30.0,
                                              );
                                      },
                                    ))),
                        if (_photoList == null)
                          SizedBox(
                              height: 100,
                              child: SpinKitThreeBounce(
                                color: Theme.of(context).primaryColorLight,
                                size: 30.0,
                              ))
                        else ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: Text(
                                    showRec ? '✨ 你可能想分享的照片' : '從相簿中選擇',
                                    textAlign: TextAlign.left,
                                  )),
                              if (_photoList!.isEmpty && !showRec)
                                Container(
                                    width: size.width,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 34),
                                    child: Text('相簿中尚無照片',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption))
                              else
                                GridView(
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
                                        index < _photoList!.length;
                                        index++)
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedImage =
                                                  _photoList![index];
                                              selectFromRec =
                                                  showRec ? true : false;
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
                                                          _photoList![
                                                              index])))))
                                  ],
                                ),
                            ],
                          ),
                        ],
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
                                      _selectedImageFormGallery();
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
