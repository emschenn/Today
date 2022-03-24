import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;
import 'package:pichint/models/photo_model.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.0.105:3000';

  Future<Widget> getImage(path) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl + '/photo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'path': path}),
      );
      if (response.statusCode == 200) {
        // var token = json.decode(response.body)['token'];
        // print(token);
        return Image.memory(response.bodyBytes);
      } else {
        return const Text('not 200');
      }
    } catch (ex) {
      print(ex);
      return Text(ex.toString());
    }
  }

  Future<bool> uploadImage(img, filename) async {
    var formData = FormData.fromMap(
        {'image': await MultipartFile.fromBytes(img, filename: filename)});
    try {
      final response = await Dio().post(_baseUrl + '/upload',
          data: formData, onSendProgress: (int sent, int total) {});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (ex) {
      print(ex.toString());
      return false;
    }
  }
}
