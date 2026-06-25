import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/approve_application_model.dart';
import 'dart:developer' as dev;
class ApproveApplicationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<bool> approveApplication(ApproveApplicationModel request) async {
    try {
      final payload = request.tojson();
      final response = await _apiClient.post(
        ApiEndpoints.approveApplication,
        data: payload,
      );

      if (response.statusCode == 200||response.statusCode == 201) {
        dev.log("APPLICATION STATUS UPDATED SUCCESSFULLY!", name: "ApproveRepository");
        return true; 
      }
      return false;
    } on DioException catch (e) {
      dev.log("APPROVAL FAILED", name: "ApproveRepository", error: e);
      return false;
    }
  }
}