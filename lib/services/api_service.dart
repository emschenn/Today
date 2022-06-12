// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/models/user_model.dart';
import 'package:pichint/services/global_service.dart';

class RecommendResults {
  final List<String> images;
  final List<String> paths;

  const RecommendResults({required this.images, required this.paths});

  factory RecommendResults.fromJson(Map<String, dynamic> json) {
    return RecommendResults(
        images: List<String>.from(json['images']),
        paths: List<String>.from(json['paths']));
  }
}

class ApiService {
  String baseUrl = 'http://rose.csie.ntu.edu.tw:7700/';

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

  Future<bool> uploadImage(image, user, description, recIndex, recPath) async {
    bool isSuccess;

    var formData = FormData.fromMap({
      'image': image,
      'user': json.encode(user),
      'description': description,
      'rec_index': recIndex,
      'rec_path': recPath
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

  Future<bool> deleteImage(group, photo, uid) async {
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
          'uid': uid,
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

  Future<bool> sendViewedNotification(
      userName, authorId, photo, count, sendNotification) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/notify/viewed'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_name': userName,
          'author_id': authorId,
          'photo': photo,
          'count': count,
          'send_notification': sendNotification
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
}
