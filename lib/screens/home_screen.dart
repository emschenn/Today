import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pichint/screens/info_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:pichint/config/icons.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/widgets/sliding_up_panel.dart';

import 'package:pichint/screens/add_screen.dart';
import 'package:pichint/screens/library_screen.dart';
import 'package:pichint/screens/photo_screen.dart';
import 'package:pichint/screens/setting_screen.dart';
import 'package:pichint/screens/timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late PageController _pageController;
  late PanelController _settingPanelController,
      _addPanelController,
      _infoPanelController,
      _photoViewController;
  late bool openAdd;
  PhotoData? openedPhoto;
  Image? openedPhotoImg;

  @override
  void initState() {
    _currentIndex = 0;
    openAdd = false;

    _pageController = PageController();
    _settingPanelController = PanelController();
    _addPanelController = PanelController();
    _photoViewController = PanelController();
    // _addPanelController.hide();
    super.initState();
  }

  void setOpenedPhoto(photo, image) {
    setState(() {
      openedPhoto = photo;
      openedPhotoImg = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var _screens = [
      TimelineScreen(
          setPhotoData: setOpenedPhoto, panelController: _photoViewController),
      const LibraryScreen(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            children: _screens,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) {},
            controller: _pageController,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              elevation: 0,
              centerTitle: false,
              title: const Text('', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              leading: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _settingPanelController.open();
                },
                icon: const Icon(
                  CustomIcon.user,
                  color: Colors.black,
                ),
              ),
              actions: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    _addPanelController.open();
                  },
                  color: Colors.black,
                  icon: const Icon(CustomIcon.play),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    _addPanelController.open();
                  },
                  color: Colors.black,
                  icon: const Icon(
                    CustomIcon.plus,
                  ),
                ),
              ],
            ),
          ),
          // BottomNavigationBar(
          //     elevation: 0,
          //     backgroundColor: Colors.white,
          //     selectedItemColor: Colors.black,
          //     unselectedItemColor: Colors.black45,
          //     currentIndex: _currentIndex,
          //     showSelectedLabels: false,
          //     showUnselectedLabels: false,
          //     onTap: ((index) {
          //       setState(() => _currentIndex = index);
          //       _pageController.animateToPage(index,
          //           duration: const Duration(milliseconds: 500),
          //           curve: Curves.easeInOut);
          //     }),
          //     items: const [
          //       BottomNavigationBarItem(
          //         icon: Icon(
          //           CustomIcon.picture,
          //           size: 24,
          //         ),
          //         activeIcon: Icon(
          //           CustomIcon.picture,
          //           size: 28,
          //         ),
          //         label: 'Timeline',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(
          //           CustomIcon.heart_filled,
          //           size: 24,
          //         ),
          //         activeIcon: Icon(
          //           CustomIcon.heart_filled,
          //           size: 28,
          //         ),
          //         label: 'Library',
          //       ),
          //     ]),

          CustomSlidingUpPanel(
              panelController: _settingPanelController,
              content: const SettingScreen()),
          CustomSlidingUpPanel(
              panelController: _addPanelController, content: const AddScreen()),
          CustomSlidingUpPanel(
              panelController: _photoViewController,
              content: openedPhoto != null
                  ? PhotoScreen(photo: openedPhoto!, image: openedPhotoImg!)
                  : Container())
        ],
      ),
    );
  }
}
