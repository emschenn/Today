import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;

class ApiService {
  String baseUrl = 'http://172.20.10.9:3000';

  Future<Uint8List?> getImage(path) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/photo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'path': path}),
      );
      if (response.statusCode == 200) {
        // var token = json.decode(response.body)['token'];
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (ex) {
      return null;
    }
  }

  Future<bool> uploadImage(img, filename) async {
    bool isSuccess;
    var formData = FormData.fromMap(
        {'image': MultipartFile.fromBytes(img, filename: filename)});
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

  Future<bool> calcImageValue(img, filename) async {
    bool isSuccess;
    var formData = FormData.fromMap(
        {'image': MultipartFile.fromBytes(img, filename: filename)});
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
}
