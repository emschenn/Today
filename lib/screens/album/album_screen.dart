import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pichint/models/album_model.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/utils/datetime.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/album/date_text.dart';
import 'package:pichint/screens/album/photos_grid_view.dart';
import 'package:provider/provider.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen>
    with AutomaticKeepAliveClientMixin {
  final database = FirebaseDatabase.instance.ref();
  ScrollController _scrollController = ScrollController();
  FirebaseService firebaseHandler = FirebaseService();
  late Map<DateTime, List<PhotoData>> _preprocessedData, _currentShownData;

  @override
  void initState() {
    _preprocessedData = {};
    _currentShownData = {};
    _scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    // if (_scrollController.position.extentAfter < 100) {
    //   _loadData(false, _preprocessedData);
    // }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Map<DateTime, List<PhotoData>> _getPreprocessedData(data) {
    List<PhotoData> photos = List.from(data.reversed);
    DateTime date = photos[0].date!;
    List<PhotoData> photoSect = [];
    Map<DateTime, List<PhotoData>> map = <DateTime, List<PhotoData>>{};
    for (var photo in photos) {
      if (isSameDate(date, photo.date!)) {
        photoSect.add(photo);
      } else {
        map[date] = photoSect;
        photoSect = [];
        photoSect.add(photo);
        date = photo.date!;
      }
    }
    map[date] = photoSect;
    return map;
  }

  Map<DateTime, List<PhotoData>>? _loadData(
      bool init, Map<DateTime, List<PhotoData>> data) {
    int currentCounts = _currentShownData.length;
    if (currentCounts < _preprocessedData.length) {
      var start = currentCounts;
      var end = start + 4 < data.length ? start + 4 : data.length;
      var keysToAdd = data.keys.toList().sublist(start, end);
      var valuesToAdd = data.values.toList().sublist(start, end);
      Map<DateTime, List<PhotoData>> dataToAdd = {
        for (int i = 0; i < keysToAdd.length; i++) keysToAdd[i]: valuesToAdd[i]
      };
      if (!init) {
        setState(() {
          _currentShownData = Map.from(_currentShownData)..addAll(dataToAdd);
        });
      } else {
        _currentShownData = Map.from(_currentShownData)..addAll(dataToAdd);
      }
      return Map.from(_currentShownData)..addAll(dataToAdd);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Consumer<AlbumModel>(builder: (context, model, child) {
      if (model.photos == null) {
        return const Center(
            child: SpinKitThreeBounce(
          color: Colors.black45,
          size: 30.0,
        ));
      }
      if (model.photos!.isNotEmpty) {
        _preprocessedData = _getPreprocessedData(model.photos);
        // var data = _loadData(true, _preprocessedData);
        return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
                children: _preprocessedData.entries.map((entry) {
              var date = DateText(date: entry.key);
              var grid = PhotosGridView(
                photos: entry.value,
              );
              return Column(children: [date, grid]);
            }).toList()));
      } else {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/empty.png', width: size.width * 0.6),
            Text('尚未分享任何照片', style: Theme.of(context).textTheme.bodyText2),
            const SizedBox(
              height: 10,
            ),
            Text('點擊右上角的＋按鈕\n用照片分享你的生活 !',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption),
            SizedBox(
              height: AppBar().preferredSize.height,
            )
          ],
        ));
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
