import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/orders/data/models/OrderModel.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient apiClient;

  OrdersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await apiClient.dio.get('/orders');
      final data = unwrapList(response.data);
      return data
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
