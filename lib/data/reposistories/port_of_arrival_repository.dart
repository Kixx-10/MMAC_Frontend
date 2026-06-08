import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/data/models/type_of_travel_models.dart';
import '../../../../core/network/api_client.dart';
class PortOfArrivalRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<PortOfArrival>> fetchPortOfArrival(int modeOfTravelId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.portOfArrival(modeOfTravelId));

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data;
        return dataList.map((json) => PortOfArrival.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("❌ API Error: ${e.message}");
      throw Exception('Failed to load port of arrival from API');
    }
  }
}