import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; 
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/network/api_client.dart'; 
import 'package:mmac/data/models/send_email_model.dart';

part 'sendEmail_service.g.dart'; 

@riverpod
class SendEmailService extends _$SendEmailService {
  
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> sendEmail(SendEmailModel model) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;

      final response = await dio.post(
        ApiEndpoints.sendEmail,
        data: model.toJson(), 
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
        return true;
      }
      
      state = AsyncValue.error("Server Error", StackTrace.current);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}