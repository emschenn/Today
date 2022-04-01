import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pichint/screens/info_screen.dart';
import 'package:pichint/services/api_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:pichint/config/icons.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/widgets/sliding_up_panel.dart';

import 'package:pichint/screens/add/add_screen.dart';
import 'package:pichint/screens/library_screen.dart';
import 'package:pichint/screens/photo/photo_screen.dart';
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
  @override
  void initState() {
    // _addPanelController.hide();
    super.initState();
    _fetchPhotosFromLibrary();
  }

  void setOpenedPhoto(photo, image) {
    setState(() {});
  }

  void _fetchPhotosFromLibrary() async {
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
      ApiService().calcImageValue(imgList, '');
    } else {
      // if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              top: AppBar().preferredSize.height,
              child: const TimelineScreen()),
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
                  Navigator.pushNamed(context, '/setting');
                },
                icon: const Icon(
                  // CustomIcon.user,
                  Icons.notifications,
                  color: Colors.black,
                ),
              ),
              actions: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0))),
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
                    )),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
