// lib/data/repositories/file_upload_repository.dart
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mmac/core/constants/api_endpoints.dart'; 
import 'package:mmac/core/network/api_client.dart';

class FileUploadRepository {
  final ApiClient _apiClient = ApiClient();

  Future<String?> uploadHealthRecord(File file) async {
    try {
      final String fileName = file.path.split('/').last;
      
      //  Build multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      dev.log(
        "UPLOADING HEALTH RECORD: $fileName",
        name: "FileUploadRepository",
      );

      // 2. Post to API using ApiEndpoints
      final response = await _apiClient.post(
        ApiEndpoints.healthRecord, 
        data: formData,
      );

      //  Handle Success
      if (response.statusCode == 200 && response.data != null) {
        dev.log(
          "HEALTH RECORD UPLOADED SUCCESSFULLY",
          name: "FileUploadRepository",
        );
        return response.data['fileUrl'] as String?;
      }
      
      return null;
    } on DioException catch (e) {
      _logError("HEALTH RECORD UPLOAD FAILED", e);
      return null;
    } catch (e) {
      _logError("GENERAL UPLOAD ERROR", e);
      return null;
    }
  }

  void _logError(String title, Object e) {
    dev.log(title, name: "FileUploadRepository", error: e);
    if (e is DioException) {
      if (e.response != null) {
        dev.log(
          "[SERVER STATUS CODE]: ${e.response?.statusCode}",
          name: "FileUploadRepository",
        );
        dev.log(
          "[SERVER ERROR DATA]: ${e.response?.data}",
          name: "FileUploadRepository",
        );
      }
    }
  }
}