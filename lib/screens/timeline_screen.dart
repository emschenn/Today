import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/utils/datetime.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/photo_screen.dart';
import 'package:pichint/widgets/date_text.dart';
import 'package:pichint/widgets/photos_grid_view.dart';

List<PhotoData> data2 = [
  PhotoData(
      id: '1',
      author: "陳",
      description:
          "純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎",
      path: "images/test.jpg",
      date: DateTime.parse('2020-01-01')),
  PhotoData(
      id: '2',
      author: "amy",
      description:
          "純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎純非下去了嗎非下去了嗎純非下去了嗎",
      path: "images/2.jpg",
      date: DateTime.parse('2020-01-01')),
  PhotoData(
      id: '3',
      author: "amy",
      description: "2",
      path: "images/3.jpg",
      date: DateTime.parse('2020-01-01')),
  PhotoData(
      id: '4',
      author: "amy",
      description: "2",
      path: "images/4.jpg",
      date: DateTime.parse('2020-01-02')),
  PhotoData(
      id: '5',
      author: "amy",
      description: "2",
      path: "images/5.jpg",
      date: DateTime.parse('2020-01-02')),
];

class TimelineScreen extends StatefulWidget {
  final PanelController panelController;
  final Function setPhotoData;

  const TimelineScreen({
    Key? key,
    required this.panelController,
    required this.setPhotoData,
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
  late Map<DateTime, List<PhotoData>> _preprocessedData;
  late List<Widget> _photosView;
  late StreamSubscription _groupsPhotoStream;
  PhotoData? openedPhoto;

  @override
  void initState() {
    _photosView = [];
    _preprocessedData = {};
    _storage.read(key: 'uid').then((uid) {
      firebaseHandler.getUserData(uid).then((user) {
        _activateListener(user.group);
      });
    });
    _scrollController = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _activateListener(group) {
    _groupsPhotoStream =
        database.child('/groups/$group').onValue.listen((event) {
      // print(event.snapshot.value);
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      final pid = json.keys;
      List<PhotoData> photos = [];
      for (int i = 0; i < json.keys.length; i++) {
        PhotoData p = PhotoData.fromJson(
          pid.elementAt(i),
          json.values.elementAt(i),
        );
        photos.add(p);
      }

      setState(() {
        _preprocessedData = _getPreprocessedData(photos);
      });
      _loadView();
    });
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 100) {
      _loadView();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void deactivate() {
    _groupsPhotoStream.cancel();
    super.deactivate();
  }

  Map<DateTime, List<PhotoData>> _getPreprocessedData(photos) {
    // List<PhotoData> photos = List.from(data.reversed);
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
              setPhotoData: widget.setPhotoData,
              photos: photoList[i],
              panelController: widget.panelController));
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
          const SizedBox(
            height: 60,
          ),
          ..._photosView,
          const SizedBox(
            height: 100,
          ),
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
