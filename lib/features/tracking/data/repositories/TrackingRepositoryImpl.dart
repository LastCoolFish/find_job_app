import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/tracking/data/datasources/TrackingRemoteDataSource.dart';
import 'package:find_job_app/features/tracking/domain/entities/EventEntity.dart';
import 'package:find_job_app/features/tracking/domain/repositories/TrackingRepository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<EventEntity>> createEvent({
    required int userId,
    required EventType eventType,
    int? vacancyId,
    int? orderId,
    int? durationSeconds,
    Map<String, dynamic>? payload,
  }) =>
      _guard(() => remoteDataSource.createEvent(
            userId: userId,
            eventType: eventType,
            vacancyId: vacancyId,
            orderId: orderId,
            durationSeconds: durationSeconds,
            payload: payload,
          ));

  @override
  Future<Result<Map<int, int>>> getVacanciesViews(List<int> vacancyIds) =>
      _guard(() => remoteDataSource.getVacanciesViews(vacancyIds));

  @override
  Future<Result<Map<int, int>>> getOrdersViews(List<int> orderIds) =>
      _guard(() => remoteDataSource.getOrdersViews(orderIds));

  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
