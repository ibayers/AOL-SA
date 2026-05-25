import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    if (_instance != null) return _instance!;
    _instance = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _instance!.interceptors.add(AuthInterceptor());
    return _instance!;
  }
}
