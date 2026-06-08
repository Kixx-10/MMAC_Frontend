import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/location_models.dart';

class LocationRepository {
  final ApiClient _apiClient = ApiClient();

//Myanmar locations Repo
  Future<List<StateContainerModel>> fetchMyanmarLocations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.address);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data;
       
        return dataList.map((json) => StateContainerModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("❌ API Error: ${e.message}");
      throw Exception('Failed to load locations from API');
    }
  }

  
}