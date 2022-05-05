import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pichint/models/photo_model.dart';

class AlbumModel extends ChangeNotifier {
  List<PhotoData>? _photos;

  final _database = FirebaseDatabase.instance;
  late StreamSubscription _photosStream;
  List<PhotoData>? get photos => _photos;

  AlbumModel(group) {
    _listenToPhotosUpdate(group);
  }

  void _listenToPhotosUpdate(group) {
    _photosStream = _database
        .ref('groups/$group/photos')
        .orderByKey()
        .onValue
        .listen((event) {
      _photos = event.snapshot.children.map((child) {
        return PhotoData.fromJson(
            child.key, child.value as Map<dynamic, dynamic>);
      }).toList();
      notifyListeners();
    });
  }

  @override
  dispose() {
    _photosStream.cancel();
    super.dispose();
  }
}
