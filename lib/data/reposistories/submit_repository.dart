// lib/data/reposistories/submit_repository.dart
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/models/submit_response_model.dart';

class SubmitRepository {
  final ApiClient _apiClient = ApiClient();

  Future<SubmitResponseModel?> submitApplication(
    SubmitRequestModel submitRequestModel,
  ) async {
    try {
      final payload = submitRequestModel.toJson();

      // 🚀 ဆာဗာဆီ ပို့လိုက်တဲ့ JSON Payload ကို Console မှာ ကြည့်ရှုရန်
      dev.log("SENDING JSON PAYLOAD: $payload", name: "SubmitRepository");

      final response = await _apiClient.post(
        ApiEndpoints.submitApplication,
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        dev.log(
          "✅ APPLICATION SUBMITTED SUCCESSFULLY!",
          name: "SubmitRepository",
        );
        return SubmitResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      dev.log("❌ SUBMISSION FAILED", name: "SubmitRepository", error: e);

      // 🛠️ 400 Bad Request အသေးစိတ် Error Message များကို ထုတ်ပြပေးမည့်စနစ်
      if (e is DioException) {
        if (e.response != null) {
          dev.log(
            "🚨 [SERVER STATUS CODE]: ${e.response?.statusCode}",
            name: "SubmitRepository",
          );
          dev.log(
            "🚨 [SERVER VALIDATION ERROR DETAILS]: ${e.response?.data}",
            name: "SubmitRepository",
          );
        } else {
          dev.log(
            "🚨 [NETWORK ERROR / NO RESPONSE FROM SERVER]: ${e.message}",
            name: "SubmitRepository",
          );
      
      if (e is DioException) {
        if (e.response != null) {
          dev.log(" [SERVER STATUS CODE]: ${e.response?.statusCode}", name: "SubmitRepository");
          dev.log(" [SERVER VALIDATION ERROR DETAILS]: ${e.response?.data}", name: "SubmitRepository");
        } else {
          dev.log(" [NETWORK ERROR / NO RESPONSE FROM SERVER]: ${e.message}", name: "SubmitRepository");
        }
      }
      throw Exception('Failed to submit application: $e');
    }
  }

  //Get Application by ID
  // lib/data/repositories/submit_repository.dart ထဲမှာ ထည့်ရန်

  Future<SubmitRequestModel?> fetchApplicationForUpdate({
    required String qrReference,
    required String email,
    required String passportNumber,
  }) async {
    try {
      // 🚀 API ဆီ ပို့မယ့် Search Parameters Payload
      final payload = {
        'qrReference': qrReference,
        'email': email,
        'passportNumber': passportNumber,
      };

      dev.log(
        "🔍 FETCHING APPLICATION WITH PAYLOAD: $payload",
        name: "SubmitRepository",
      );

      // စီနီယာ့ရဲ့ ApiEndpoints ထဲမှာ လမ်းကြောင်းအသစ် ထည့်ပေးထားရပါမယ်
      final response = await _apiClient.post(
        '/application/search', // ApiEndpoints.searchApplication လို့ ပြောင်းသုံးနိုင်သည်
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        dev.log("✅ APPLICATION RECORD FOUND!", name: "SubmitRepository");

        // Server က ပြန်လာတဲ့ အချက်အလက်တွေကို SubmitRequestModel အဖြစ် ပြန်ပြောင်းပြီး Return ပေးခြင်း
        return SubmitRequestModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      dev.log("❌ FETCH APPLICATION FAILED", name: "SubmitRepository", error: e);

      if (e is DioException) {
        if (e.response != null) {
          dev.log(
            "🚨 [STATUS CODE]: ${e.response?.statusCode}",
            name: "SubmitRepository",
          );
          dev.log(
            "🚨 [SERVER ERROR]: ${e.response?.data}",
            name: "SubmitRepository",
          );
        }
      }
      return null;
    }
  }
}
