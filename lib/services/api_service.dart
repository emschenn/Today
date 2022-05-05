import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/global_service.dart';

class RecommendResults {
  final List<String> images;

  const RecommendResults({required this.images});

  factory RecommendResults.fromJson(Map<String, dynamic> json) {
    return RecommendResults(images: List<String>.from(json['images']));
  }
}

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

class ApiService {
  String baseUrl = 'http://192.168.0.102:7700';

  Future<bool> checkIsServerAlive() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      return false;
    }
  }

  Future<bool> uploadImage(image, user, description) async {
    bool isSuccess;
    var formData = FormData.fromMap({
      'image': image,
      'user': json.encode(user),
      'description': description
    });
    try {
      final response = await Dio().post(baseUrl + '/upload',
          data: formData, onSendProgress: (int sent, int total) {});
      if (response.statusCode == 200) {
        isSuccess = true;
      } else {
        isSuccess = false;
      }
    } on DioError catch (ex) {
      print(ex.toString());
      isSuccess = false;
    }
    return isSuccess;
  }

  Future<bool> deleteImage(group, photo) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'filename': photo.filename,
          'group': group,
          'pid': photo.pid,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      return false;
    }
  }

  Future<bool> collectImages() async {
    print('Collect Images...');
    UserData? user = GlobalService().getUserData;
    var requestGallery = await PhotoManager.requestPermission();
    if (!requestGallery || user == null) {
      return false;
    }
    print('go');
    var uid = user.uid;
    var currentTimestamp = user.latestTimestamp;

    List<MultipartFile> imgList = [];
    List<GeoData> imgGeoDataList = [];
    List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    List<AssetEntity> latestImg = await albums[0].getAssetListPaged(0, 1);
    var latestTimestamp = latestImg[0].createDtSecond;
    var imgTimestamp = latestTimestamp;
    print('latest img: ' + imgTimestamp.toString());
    print('owned latest img: ' + currentTimestamp.toString());
    if (imgTimestamp == currentTimestamp) return true;

    var start = 0, end = 10;
    while (imgTimestamp! > currentTimestamp!) {
      List<AssetEntity> media =
          await albums[0].getAssetListRange(start: start, end: end);
      for (var img in media) {
        imgTimestamp = img.createDtSecond!;
        print('latest img: ' + imgTimestamp.toString());
        print('owned latest img: ' + currentTimestamp.toString());
        if (imgTimestamp <= currentTimestamp) {
          break;
        }
        await img
            .thumbDataWithSize(600, 600 * img.height ~/ img.width)
            .then((value) {
          var filename = '${img.createDtSecond}.jpg';
          var file = MultipartFile.fromBytes(value!, filename: filename);
          imgList.add(file);
          GeoData geoData =
              GeoData(latitude: img.latitude, longitude: img.longitude);
          imgGeoDataList.add(geoData);
        });
      }
      start = end;
      end = start + 10;
      print('from ${start.toString()}  to ${end.toString()}');
      if (start > 100) break;
    }

    bool isSuccess = false;
    print('total img count: ${imgList.length}');
    print(imgGeoDataList);
    var formData = FormData.fromMap({
      'images': imgList,
      'uid': uid,
      'geo_data': const JsonEncoder().convert(imgGeoDataList)
    });
    try {
      final response = await Dio().post(baseUrl + '/upload/imgs',
          data: formData, onSendProgress: (int sent, int total) {});
      if (response.statusCode == 200) {
        isSuccess = true;
        await FirebaseService().updateLatestTimestamp(uid, latestTimestamp);
      } else {
        isSuccess = false;
      }
    } on DioError catch (ex) {
      print(ex.toString());
      isSuccess = false;
    }
    return isSuccess;
  }

  Future<RecommendResults?> getRecommendedImage(uid) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/recommend'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'uid': uid}),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return RecommendResults.fromJson(data);
      } else {
        return null;
      }
    } catch (ex) {
      return null;
    }
  }

  Future<bool> sendViewCountNotification(uid, pid, count) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/notify/view'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'uid': uid, 'pid': pid, 'count': count}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      return false;
    }
  }
}
