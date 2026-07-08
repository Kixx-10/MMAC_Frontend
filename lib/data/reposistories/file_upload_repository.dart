// lib/data/repositories/file_upload_repository.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmac/core/constants/api_endpoints.dart'; 
import 'package:mmac/core/network/api_client.dart';

class FileUploadRepository {
  final ApiClient _apiClient = ApiClient();

 Future<String?> uploadHealthRecord(Uint8List bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.healthRecord, 
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['fileUrl'] as String?;
      }
      return null;
    } catch (e) {
      // _logError ကို အသုံးမပြုတော့ရင် ဒီမှာပဲ print ထုတ်ထားပါ
      debugPrint("Upload Error: $e");
      return null;
    }
  }
}

