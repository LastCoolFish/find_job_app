import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';

abstract class OrdersRepository {
  /// Orders matching [filters], page by page (newest first by default).
  Future<Result<List<OrderEntity>>> getOrders({
    OrderFilters filters = const OrderFilters(),
    int offset = 0,
    int limit = 20,
  });

  /// Distinct platform codes, e.g. ['fl', 'kwork'].
  Future<Result<List<String>>> getPlatforms();
}
