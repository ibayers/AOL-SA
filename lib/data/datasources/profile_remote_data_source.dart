import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/domain/models/models.dart';

class ProfileRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<ProfileModel> getProfile() async {
    final response = await _dio.get(ApiConfig.profile);
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await _dio.patch(
      ApiConfig.profile,
      data: profile.toJson(),
    );
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
