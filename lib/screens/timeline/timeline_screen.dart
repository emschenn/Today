import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/utils/datetime.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/timeline/date_text.dart';
import 'package:pichint/screens/timeline/photos_grid_view.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with AutomaticKeepAliveClientMixin {
  final database = FirebaseDatabase.instance.ref();
  final _storage = const FlutterSecureStorage();
  ScrollController _scrollController = ScrollController();
  FirebaseService firebaseHandler = FirebaseService();
  late Map<DateTime, List<PhotoData>> _preprocessedData, _currentShownData;
  late List<Widget> _photosView;
  // late StreamSubscription _groupsPhotoStream;
  PhotoData? openedPhoto;

  @override
  void initState() {
    _photosView = [];
    _preprocessedData = {};
    _currentShownData = {};
    _storage.read(key: 'uid').then((uid) {
      firebaseHandler.getUserData(uid).then((user) {
        _activateListener(user.group);
      });
    });
    _scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _activateListener(group) async {
    List<PhotoData> photos = [];
    FirebaseList(
        query: database.child('/groups/$group'),
        onValue: (snapshot) {
          print('onValue');
          snapshot.children.forEach((child) {
            PhotoData p = PhotoData.fromJson(
                child.key, child.value as Map<dynamic, dynamic>);
            photos.add(p);
          });
          if (photos.isNotEmpty) {
            setState(() {
              _preprocessedData = _getPreprocessedData(photos);
            });
            _loadData(true);
          }
        });
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 100) {
      _loadData(false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void deactivate() {
    // _groupsPhotoStream.cancel();
    super.deactivate();
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

  void _loadData(bool refresh) {
    int currentCounts = _currentShownData.length;
    if (currentCounts < _preprocessedData.length) {
      var start = currentCounts;
      var end = start + 4 < _preprocessedData.length
          ? start + 4
          : _preprocessedData.length;
      var keysToAdd = _preprocessedData.keys.toList().sublist(start, end);
      var valuesToAdd = _preprocessedData.values.toList().sublist(start, end);
      Map<DateTime, List<PhotoData>> dataToAdd = {
        for (int i = 0; i < keysToAdd.length; i++) keysToAdd[i]: valuesToAdd[i]
      };
      setState(() {
        _currentShownData = Map.from(_currentShownData)..addAll(dataToAdd);
      });
    }
  }

  void _loadView() {
    int currentCounts = _photosView.isEmpty ? 0 : _photosView.length ~/ 2;
    if (currentCounts < _preprocessedData.length) {
      var start = currentCounts;
      var end = start + 4 < _preprocessedData.length
          ? start + 4
          : _preprocessedData.length;
      var dateList = _preprocessedData.keys.toList().sublist(start, end);
      var photoList = _preprocessedData.values.toList().sublist(start, end);
      for (var i = 0; i < dateList.length; i++) {
        setState(() {
          _photosView.add(DateText(date: dateList[i]));
          _photosView.add(PhotosGridView(
            photos: photoList[i],
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          if (_currentShownData.isNotEmpty)
            ..._currentShownData.entries.map((entry) {
              var date = DateText(date: entry.key);
              var grid = PhotosGridView(
                photos: entry.value,
              );
              return Column(children: [date, grid]);
            }).toList(),
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
