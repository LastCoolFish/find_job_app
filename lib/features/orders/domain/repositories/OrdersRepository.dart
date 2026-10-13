import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';

abstract class OrdersRepository {
  Future<Result<List<OrderEntity>>> getOrders();
}
