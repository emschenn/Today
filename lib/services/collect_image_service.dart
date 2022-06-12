import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/firebase_service.dart';

class GeoData {
  double? longitude;
  double? latitude;

  GeoData({
    this.longitude,
    this.latitude,
  });

  GeoData.fromJson(Map<dynamic, dynamic> json, String id) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}

class CollectedImage {
  List<MultipartFile>? imgList;
  List<GeoData>? geoList;
  int? latestTimestamp;

  CollectedImage({
    this.imgList,
    this.geoList,
    this.latestTimestamp,
  });

  CollectedImage.fromJson(Map<dynamic, dynamic> json, String id) {
    imgList = json['imgList'];
    geoList = json['longitude'];
    latestTimestamp = json['latestTimestamp'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['imgList'] = imgList;
    data['latitude'] = geoList;
    data['latestTimestamp'] = latestTimestamp;
    return data;
  }
}

Future<UserData?> collectImagesSetUp() async {
  var uid = await const FlutterSecureStorage().read(key: 'uid');
  if (uid == null) return null;
  await Firebase.initializeApp();
  UserData? user = await FirebaseService().getUserData(uid);
  return user;
}

Future<CollectedImage> collectImagesFromLibrary(user) async {
  print('Preparing Collect Images...');
  PhotoManager.setIgnorePermissionCheck(true);
  var currentTimestamp = user.latestTimestamp;
  print('Start Collecting Images...');
  List<MultipartFile> imgList = [];
  List<GeoData> imgGeoDataList = [];
  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);
  List<AssetEntity> latestImg = await albums[0].getAssetListPaged(0, 1);
  var latestTimestamp = latestImg[0].createDtSecond;
  var imgTimestamp = latestTimestamp;
  print('latest img: ' + imgTimestamp.toString());
  print('owned latest img: ' + currentTimestamp.toString());
  if (currentTimestamp >= imgTimestamp) {
    return CollectedImage(imgList: [], geoList: []);
  }
  var start = 0, end = 10;
  while (imgTimestamp! > currentTimestamp!) {
    List<AssetEntity> media =
        await albums[0].getAssetListRange(start: start, end: end);
    for (var img in media) {
      imgTimestamp = img.createDtSecond!;
      if (imgTimestamp <= currentTimestamp) break;
      var type = await img.titleAsync;
      if (type.split(".")[1] == 'PNG') continue;
      if (img.height == 0 || img.width == 0) continue;
      await img
          .thumbDataWithSize(600, 600 * img.height ~/ img.width)
          .then((value) {
        var filename = '${img.createDtSecond}.jpg';
        var file = MultipartFile.fromBytes(value!, filename: filename);
        imgList.add(file);
        GeoData geoData = GeoData(
          latitude: img.latitude,
          longitude: img.longitude,
        );
        imgGeoDataList.add(geoData);
      });
    }
    start = end;
    end = start + 10;
    if (start > 100) break;
  }
  print('total img count: ${imgList.length}');
  return CollectedImage(
      imgList: imgList,
      geoList: imgGeoDataList,
      latestTimestamp: latestTimestamp);
}

Future<bool> sendCollectedImagesToServer(
    CollectedImage collectedImage, UserData user) async {
  bool isSuccess = false;
  var formData = FormData.fromMap({
    'images': collectedImage.imgList,
    'uid': user.uid,
    'geo_data': const JsonEncoder().convert(collectedImage.geoList)
  });
  try {
    final response = await Dio().post(
        'http://rose.csie.ntu.edu.tw:7700/upload/imgs',
        data: formData,
        onSendProgress: (int sent, int total) {});
    if (response.statusCode == 200) {
      isSuccess = true;
      await FirebaseService()
          .updateLatestTimestamp(user.uid, collectedImage.latestTimestamp);
    } else {
      isSuccess = false;
    }
  } on DioError catch (ex) {
    print(ex.toString());
    isSuccess = false;
  }
  return isSuccess;
}
