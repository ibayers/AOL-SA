import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/core/network/auth_interceptor.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiConfig.login,
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final token = response.data['access_token'] as String;
    await AuthInterceptor.saveToken(token);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      ApiConfig.register,
      data: {
        'name': name,
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    final token = response.data['access_token'] as String;
    await AuthInterceptor.saveToken(token);
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post(ApiConfig.logout);
    await AuthInterceptor.clearToken();
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get(ApiConfig.me);
    return response.data as Map<String, dynamic>;
  }
}
