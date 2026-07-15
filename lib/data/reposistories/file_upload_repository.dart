// lib/data/repositories/file_upload_repository.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmac/core/constants/api_endpoints.dart'; 
import 'package:mmac/core/network/api_client.dart';

class FileUploadRepository {
  final ApiClient _apiClient = ApiClient();


Future<Map<String, String>?> uploadHealthRecord(Uint8List bytes, String fileName) async {
  try {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _apiClient.post(ApiEndpoints.healthRecord, data: formData);

    if (response.statusCode == 200 && response.data != null) {
      return {
        'fileUrl': response.data['fileUrl'] as String,
        'originalFileName':
            (response.data['originalFileName'] as String?) ?? fileName,
      };
    }
    return null;
  } catch (e) {
    debugPrint("Upload Error: $e");
    return null;
  }
}
Future<Map<String, String>?> uploadDigitalRecord(Uint8List bytes, String fileName) async {
  try {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _apiClient.post(ApiEndpoints.digitalRecord, data: formData);

    if (response.statusCode == 200 && response.data != null) {
      return {
        'fileUrl': response.data['fileUrl'] as String,
        'originalFileName': (response.data['originalFileName'] as String?) ?? fileName,
      };
    }
    return null;
  } catch (e) {
    debugPrint("Digital Upload Error: $e");
    return null;
  }
}
}

