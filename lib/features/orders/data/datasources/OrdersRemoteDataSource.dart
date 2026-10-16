import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/orders/data/models/OrderModel.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';

abstract class OrdersRemoteDataSource {
  /// Orders matching [filters], page by page (newest first by default).
  Future<List<OrderModel>> getOrders({
    OrderFilters filters = const OrderFilters(),
    int offset = 0,
    int limit = 20,
  });

  /// Distinct platform codes, e.g. ['fl', 'kwork'].
  Future<List<String>> getPlatforms();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient apiClient;

  OrdersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<OrderModel>> getOrders({
    OrderFilters filters = const OrderFilters(),
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // /search with no filters returns the same as /orders.
      final response = await apiClient.dio.get(
        '/orders/search',
        queryParameters: {
          ...filters.toQueryParameters(),
          'offset': offset,
          'limit': limit,
        },
      );
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

  @override
  Future<List<String>> getPlatforms() async {
    try {
      final response = await apiClient.dio.get('/orders/platforms');
      return (response.data as List<dynamic>).cast<String>();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
