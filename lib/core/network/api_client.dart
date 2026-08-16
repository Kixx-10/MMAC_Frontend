import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  final _storage = const FlutterSecureStorage();
  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        // Render Live Backend URL
        baseUrl: "https://mmac-backend.onrender.com/api/",
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Render free tier တွင် Cold Start ကြောင့် ပထမဆုံး request ကြာမြင့်နိုင်သည့်အတွက် Handle လုပ်ရန်
          if (e.type == DioExceptionType.connectionTimeout) {
            print("Server takes too long to respond (Cold Start).");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException {
      rethrow;
    }
  }
}