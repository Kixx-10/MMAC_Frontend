// ignore_for_file: avoid_print

import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/search_request_model.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/models/submit_response_model.dart';

class SubmitRepository {
  final ApiClient _apiClient = ApiClient();

Future<SubmitResponseModel?> submitApplication(SubmitRequestModel submitRequestModel) async {
  try {
    final payload = submitRequestModel.toJson();
    final response = await _apiClient.post(ApiEndpoints.submitApplication, data: payload);
    return SubmitResponseModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response != null) {
      final responseData = e.response?.data;
      
      if (e.response?.statusCode == 400 && responseData is Map && responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        final String firstError = errors.values.first.first; 
        throw Exception(firstError); 
      }
      
      throw Exception("Server Error Occur! (Error: ${e.response?.statusCode})");
    }
  
    throw Exception("Network Connection Failed");
  } catch (e) {
    throw Exception("Something want wrong!: $e");
  }
}

  Future<SubmitResponseModel?> updateApplication(
    SubmitRequestModel updateRequestModel,
  ) async {
    try {
      final payload = updateRequestModel.toJson();
      dev.log("SENDING UPDATE PAYLOAD: $payload", name: "SubmitRepository");

      final response = await _apiClient.post(
        ApiEndpoints.submitApplication,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        dev.log("APPLICATION UPDATED SUCCESSFULLY!", name: "SubmitRepository");
        return SubmitResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      _logError("UPDATE SUBMISSION FAILED", e);
      throw Exception('Failed to update application: $e');
    }
  }

  // 🇲🇲 ၂။ မြန်မာနိုင်ငံသားများအတွက် ရှာဖွေခြင်း
  Future<SubmitRequestModel?> fetchNativeApplication(
    NativeSearchRequestModel request,
  ) async {
    try {
      final payload = request.toJson();
      dev.log(
        "VERIFYING NATIVE UPDATE WITH PAYLOAD: $payload",
        name: "SubmitRepository",
      );

      final response = await _apiClient.post(
        ApiEndpoints.findNative,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        dev.log("NATIVE RECORD FOUND AND VERIFIED!", name: "SubmitRepository");
        return SubmitRequestModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _logError("FETCH NATIVE APPLICATION FAILED", e);
      return null;
    }
  }

  // ၃။ နိုင်ငံခြားသားများအတွက် ရှာဖွေခြင်း
  Future<SubmitRequestModel?> fetchForeignerApplication(
    ForeignerSearchRequestModel request,
  ) async {
    try {
      final payload = request.toJson();
      dev.log(
        "VERIFYING FOREIGNER UPDATE WITH PAYLOAD: $payload",
        name: "SubmitRepository",
      );

      final response = await _apiClient.post(
        ApiEndpoints.findForeigner,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        dev.log(
          "FOREIGNER RECORD FOUND AND VERIFIED!",
          name: "SubmitRepository",
        );
        return SubmitRequestModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _logError("FETCH FOREIGNER APPLICATION FAILED", e);
      return null;
    }
  }

  // 💡 Error Helper Function
  void _logError(String title, Object e) {
    dev.log(title, name: "SubmitRepository", error: e);
    if (e is DioException) {
      if (e.response != null) {
        dev.log(
          "[SERVER STATUS CODE]: ${e.response?.statusCode}",
          name: "SubmitRepository",
        );
        dev.log(
          "[SERVER ERROR DETAILS]: ${e.response?.data}",
          name: "SubmitRepository",
        );
      } else {
        dev.log("[NETWORK ERROR]: ${e.message}", name: "SubmitRepository");
      }
    }
  }
}
