import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/orders/data/datasources/OrdersRemoteDataSource.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';
import 'package:find_job_app/features/orders/domain/repositories/OrdersRepository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<OrderEntity>>> getOrders({
    OrderFilters filters = const OrderFilters(),
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final orders = await remoteDataSource.getOrders(
        filters: filters,
        offset: offset,
        limit: limit,
      );
      return Success(orders);
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<List<String>>> getPlatforms() async {
    try {
      return Success(await remoteDataSource.getPlatforms());
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<OrderEntity>> getOrder(int id) async {
    try {
      return Success(await remoteDataSource.getOrder(id));
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
