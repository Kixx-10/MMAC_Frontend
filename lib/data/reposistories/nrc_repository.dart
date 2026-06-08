import 'package:dio/dio.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/nrc_model.dart';

class NrcRepository {
  final ApiClient _apiClient = ApiClient();
  Future<List<NRCStateContainerModel>>fetchNRCStates()async{
    try{
final response=await _apiClient.get(ApiEndpoints.getNRC);
    if(response.statusCode==200 && response.data!=null){
      final List<dynamic> dataList=response.data;
      return dataList.map((json) => NRCStateContainerModel.fromJson(json)).toList();
    }
    return [];
    }on DioException catch(e){
      throw Exception('Failed to load NRC states from API: $e');
    }
  }
}