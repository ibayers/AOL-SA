import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/domain/models/models.dart';

class PaymentMethodRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _dio.get(ApiConfig.paymentMethods);
    return (response.data as List)
        .map(
          (e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<PaymentMethodModel> addPaymentMethod(
    PaymentMethodModel method,
  ) async {
    final response = await _dio.post(
      ApiConfig.paymentMethods,
      data: method.toJson(),
    );
    return PaymentMethodModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePaymentMethod(String id) async {
    await _dio.delete('${ApiConfig.paymentMethods}/$id');
  }
}
