import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5021/api/",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  dio.interceptors.add(InterceptorsWrapper(
  onRequest: ((options, handler) {
  options.headers["ApiKey"] = "SecretKey1234!@#HelloMyanmar&!@#";
  return handler.next(options);
})
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters,}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException {
      rethrow;
    }
  }
}
