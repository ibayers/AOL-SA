import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/domain/models/models.dart';

class WishlistRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<WishlistItemModel>> getWishlistItems() async {
    final response = await _dio.get(ApiConfig.wishlist);
    return (response.data as List)
        .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WishlistItemModel> addWishlistItem(WishlistItemModel item) async {
    final response = await _dio.post(
      ApiConfig.wishlist,
      data: item.toJson(),
    );
    return WishlistItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WishlistItemModel> updateWishlistItem(WishlistItemModel item) async {
    final response = await _dio.put(
      '${ApiConfig.wishlist}/${item.id}',
      data: item.toJson(),
    );
    return WishlistItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteWishlistItem(String id) async {
    await _dio.delete('${ApiConfig.wishlist}/$id');
  }

  Future<WishlistItemModel> markCompleted(String id) async {
    final response = await _dio.patch('${ApiConfig.wishlist}/$id/complete');
    return WishlistItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
