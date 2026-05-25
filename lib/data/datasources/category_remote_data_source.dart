import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/domain/models/models.dart';

class CategoryRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(ApiConfig.categories);
    return (response.data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    final response = await _dio.post(
      ApiConfig.categories,
      data: category.toJson(),
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final response = await _dio.put(
      '${ApiConfig.categories}/${category.id}',
      data: category.toJson(),
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete('${ApiConfig.categories}/$id');
  }
}
