import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> _mediaList = [];

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      print(albums);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 20);
      print(media[4].file);
      print(media[4].createDateTime);
      print(media[4].latitude);
      print(media[4].longitude);
      setState(() {
        _mediaList = media;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: _mediaList.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: _mediaList[index].thumbDataWithSize(200, 200),
            builder:
                (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Image.memory(snapshot.data!);
              }
              return Container();
            },
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
