import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/models/user_model.dart';

class RecommendResults {
  final List<String> images;

  const RecommendResults({required this.images});

  factory RecommendResults.fromJson(Map<String, dynamic> json) {
    return RecommendResults(images: List<String>.from(json['images']));
  }
}

class ApiService {
  String baseUrl = 'http://192.168.0.102:3000';

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
          'query': '$group/${photo.pid}',
          'filename': photo.filename
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

  Future<bool> collectImages(data) async {
    var uid = data['uid'];
    var path = data['path'];
    var latestImgTimestamp = data['timestamp'];
    var requestGallery = await PhotoManager.requestPermission();
    if (!requestGallery) {
      return false;
    }
    List<MultipartFile> imgList = [];
    List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    List<AssetEntity> latestImg = await albums[0].getAssetListPaged(0, 1);
    var imgTimestamp = latestImg[0].createDtSecond;
    if (imgTimestamp == latestImgTimestamp) return true;
    await FirebaseService().updateLatestTimestamp(uid, imgTimestamp);
    var start = 0, end = 10;
    while (imgTimestamp! > latestImgTimestamp!) {
      List<AssetEntity> media =
          await albums[0].getAssetListRange(start: start, end: end);
      for (var img in media) {
        imgTimestamp = img.createDtSecond!;
        if (imgTimestamp <= latestImgTimestamp) {
          break;
        }
        await img
            .thumbDataWithSize(600, 600 * img.height ~/ img.width)
            .then((value) {
          var file = MultipartFile.fromBytes(value!,
              filename: '${img.createDtSecond}.jpg');
          imgList.add(file);
        });
      }
      start = end;
      end = start + 10;
    }
    bool isSuccess;
    print(imgList);
    var formData = FormData.fromMap({
      'images': imgList,
      'path': path,
    });
    try {
      final response = await Dio().post(baseUrl + '/upload/imgs',
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

  Future<RecommendResults?> getRecommendedImage(user) async {
    print(user);
    // var formData = FormData.fromMap({
    //   'user': json.encode(user),
    // });
    // try {
    //   final response = await Dio().post(baseUrl + '/recommend',
    //       data: formData, onSendProgress: (int sent, int total) {});
    //   if (response.statusCode == 200) {
    //     print(response.data);
    //     var data = Map<String, dynamic>.from(response.bodyBytes);
    //     return RecommendResults.fromJson(data);
    //   } else {
    //     return null;
    //   }
    // } on DioError catch (ex) {
    //   print(ex.toString());
    //   return null;
    // }
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/recommend'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'user': json.encode(user)}),
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
}
