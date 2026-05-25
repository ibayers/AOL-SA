import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/domain/models/models.dart';

class TransactionRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<TransactionModel>> getTransactions({
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{};
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();
    final response = await _dio.get(
      ApiConfig.transactions,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> addTransaction(TransactionModel txn) async {
    final response = await _dio.post(
      ApiConfig.transactions,
      data: txn.toJson(),
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TransactionModel> updateTransaction(TransactionModel txn) async {
    final response = await _dio.put(
      '${ApiConfig.transactions}/${txn.id}',
      data: txn.toJson(),
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('${ApiConfig.transactions}/$id');
  }
}
