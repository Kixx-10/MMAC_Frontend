import 'package:dio/dio.dart'; 
import 'package:mmac/core/network/api_client.dart';
import 'package:mmac/data/models/qr_response_model.dart';

class QrScanRepository {
  final ApiClient _apiClient = ApiClient(); 

  Future<QrResponseModel?> fetchApplicationByQrCode(String appNo) async {
    try {
    
       final String endpoint = "Application/SearchApplicationByQRCode$appNo";
      
      final response = await _apiClient.get(endpoint);

      if (response.data != null) {
        return QrResponseModel.fromJson(response.data);
      }
      return null;
      
    } on DioException catch (e) {
      if (e.response != null) {
        final String? message = e.response?.data['message'];
        if (e.response?.statusCode == 400) {
          throw Exception(message ?? "This qr is already approved");
        } else if (e.response?.statusCode == 404) {
          throw Exception("Invalid QR");
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}