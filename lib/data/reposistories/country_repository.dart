import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/country_model.dart';

class CountryRepository {
  final ApiClient _apiClient = ApiClient();
  Future<List<CountryModel>>fetchCountries(String endpoint)async{
    try{
       final response=await _apiClient.get(endpoint);
   if(response.statusCode==200 && response.data!=null){
    final List<dynamic> dataList=response.data;
    return dataList.map((json) => CountryModel.fromJson(json)).toList();
   }
   return [];
    } on DioException catch(e){
      debugPrint("❌ API Error: ${e.message}");
      throw Exception('Failed to load countries from API: $e');
      
    }
  }
} 