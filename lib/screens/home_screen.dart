import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pichint/services/collect_image_service.dart';
import 'package:pichint/services/fcm_service.dart';
import 'package:pichint/widgets/animated_dialog.dart';
import 'package:pichint/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:pichint/models/album_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/config/icons.dart';

import 'package:pichint/screens/search_screen.dart';
import 'package:pichint/screens/album/album_screen.dart';

import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/utils/show_dialog.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late PageController _pageController;
  late FocusNode _focusNode;
  late UserData user;
  late TextEditingController _textFieldController;
  late PanelController _collectImgController;
  bool _isSearch = false;
  bool _showSearchButton = true;
  bool _needUpdateCollectedImages = false;
  bool _collectingImage = false;
  String query = '';

  @override
  void initState() {
    user = GlobalService().getUserData!;
    _focusNode = FocusNode();
    _collectImgController = PanelController();
    _textFieldController = TextEditingController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _textFieldController.clear();
        setState(() {
          query = '';
        });
      }
    });
    FcmService().setUpFirebaseMessaging(context);
    _pageController = PageController();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    final curveAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: 0, end: 800).animate(curveAnimation)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
    quickActionsSetup();
    checkDataUpdate();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      ApiService().checkIsServerAlive().then((success) async {
        if (!success) {
          await showAlertDialog(
              context: context,
              title: "發生錯誤",
              content: "請確定手機是否正確連上網路後重啟 App。若問題持續發生，請聯繫研究人員 💬",
              confirmText: "確定",
              confirmAction: () {
                Navigator.of(context).pop(false);
              });
        }
      });
    });
  }

  void quickActionsSetup() async {
    const QuickActions quickActions = QuickActions();

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'collect_images',
        localizedTitle: '提供 AI 分析資料',
      ),
    ]);

    quickActions.initialize((type) async {
      if (type == 'collect_images') {
        CollectedImage collectedImage = await collectImagesFromLibrary(user);
        if (collectedImage.imgList!.isNotEmpty) {
          await sendCollectedImagesToServer(collectedImage, user);
        }
      }
    });
  }

  void checkDataUpdate() async {
    CollectedImage collectedImage = await collectImagesFromLibrary(user);
    if (collectedImage.imgList!.isNotEmpty) {
      _collectImgController.open();
      setState(() {
        _needUpdateCollectedImages = true;
      });
    }
  }

  void updateCollectedImage() async {
    setState(() {
      _collectingImage = true;
    });
    CollectedImage collectedImage = await collectImagesFromLibrary(user);
    var isUpdated = await sendCollectedImagesToServer(collectedImage, user);
    setState(() {
      if (isUpdated) {
        _needUpdateCollectedImages = false;
      }
      _collectingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SlidingUpPanel(
        backdropEnabled: true,
        renderPanelSheet: false,
        minHeight: 0,
        maxHeight: size.height,
        controller: _collectImgController,
        panel: Center(
            child: Container(
                width: size.width * 0.55,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/collecting.png',
                          width: size.width * 0.35),
                      Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 32),
                          child: Text('同步手機相簿的資料以做出分享建議',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.caption)),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomButton(
                        color: const Color.fromARGB(255, 109, 148, 124),
                        text: '同步資料',
                        textColor: Colors.white,
                        onClick: () async {
                          _collectImgController.close();
                          updateCollectedImage();
                        },
                      )
                    ]))),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ChangeNotifierProvider<AlbumModel>(
                  create: (context) =>
                      AlbumModel(GlobalService().getUserData!.group),
                  child: Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      top: AppBar().preferredSize.height,
                      child: PageView(
                        children: [
                          const AlbumScreen(),
                          SearchScreen(query: query),
                        ],
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (value) {},
                        controller: _pageController,
                      ))),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: false,
                  title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isSearch ? 1 : 0,
                      child: SizedBox(
                        width: _animation.value,
                        child: Visibility(
                            visible: _isSearch,
                            child: TextFormField(
                                controller: _textFieldController,
                                focusNode: _focusNode,
                                onFieldSubmitted: (string) {
                                  setState(() {
                                    query = string;
                                  });
                                },
                                cursorColor: Colors.black54,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: Platform.isIOS ? 8.0 : 10.0,
                                      horizontal: 20.0),
                                  hintText: '搜尋',
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50.0)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50.0)),
                                  ),
                                  hintStyle:
                                      const TextStyle(color: Colors.black45),
                                ),
                                style: Theme.of(context).textTheme.bodyText1)),
                      )),
                  leading: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSearch
                          ? Transform.translate(
                              offset: const Offset(14, 0),
                              child: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {},
                                icon: Icon(
                                  CustomIcon.search,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ))
                          : Transform.translate(
                              offset: const Offset(8, 0),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/setting');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              AssetImage('assets/header.png')),
                                    ),
                                  )))),
                  actions: [
                    AnimatedOpacity(
                        opacity: _isSearch ? 0 : 1,
                        onEnd: () {
                          if (_isSearch) {
                            setState(() {
                              _showSearchButton = false;
                            });
                          }
                        },
                        duration: const Duration(milliseconds: 50),
                        child: Visibility(
                            visible: _showSearchButton,
                            child: IconButton(
                              visualDensity: _needUpdateCollectedImages
                                  ? const VisualDensity(
                                      horizontal: 0, vertical: -4.0)
                                  : const VisualDensity(
                                      horizontal: -4.0, vertical: -4.0),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                // Navigator.pushNamed(context, '/setting');
                                setState(() {
                                  _isSearch = true;
                                  _animationController.forward();
                                  _pageController.animateToPage(1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                });
                              },
                              icon: Icon(CustomIcon.search,
                                  color: Theme.of(context).primaryColorDark),
                            ))),
                    if (_needUpdateCollectedImages)
                      AnimatedOpacity(
                          opacity: _isSearch ? 0 : 1,
                          onEnd: () {
                            if (_isSearch) {
                              setState(() {
                                _showSearchButton = false;
                              });
                            }
                          },
                          duration: const Duration(milliseconds: 50),
                          child: Visibility(
                              visible: _showSearchButton,
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 109, 148, 124),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  child: _collectingImage
                                      ? const SizedBox(
                                          width: 38,
                                          child: SpinKitThreeBounce(
                                            color: Colors.black45,
                                            size: 12.0,
                                          ))
                                      : IconButton(
                                          visualDensity: const VisualDensity(
                                              horizontal: -4.0, vertical: 4),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: () async {
                                            updateCollectedImage();
                                          },
                                          color: Colors.white,
                                          icon: const Icon(
                                            Icons.update_rounded,
                                            size: 20,
                                          ),
                                        )))),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_isSearch
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0))),
                              child: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add');
                                },
                                color: Colors.white,
                                icon: const Icon(
                                  CustomIcon.plus,
                                  size: 20,
                                ),
                              ))
                          : AnimatedOpacity(
                              opacity: _isSearch ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: TextButton(
                                  style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                  onPressed: () {
                                    setState(() {
                                      query = '';
                                      _textFieldController.clear();
                                      _isSearch = false;
                                      _showSearchButton = true;
                                      _animationController.reverse();
                                      _pageController.animateToPage(0,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                    });
                                  },
                                  child: Text('取消',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark)))),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ));
  }
}
