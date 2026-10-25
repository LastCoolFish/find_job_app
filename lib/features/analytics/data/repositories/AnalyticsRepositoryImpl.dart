import 'package:find_job_app/core/config/EnvConfig.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/data/datasources/AnalyticsRemoteDataSource.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<EngagementEntity>> getEngagement(EventTarget target) async {
    try {
      return Success(await remoteDataSource.getEngagement(target));
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<void> track(
    EventType type,
    EventTarget target, {
    int? durationSeconds,
  }) async {
    try {
      await remoteDataSource.sendEvent(
        userId: EnvConfig.currentUserId,
        type: type,
        target: target,
        durationSeconds: durationSeconds,
      );
    } on NetworkException {
      // Analytics is best-effort, see AnalyticsRepository.track.
    } on ServerException {
      // Same as above.
    }
  }

  @override
  Future<Result<List<SkillDemandEntity>>> getTopSkills(int count) =>
      _guard(() => remoteDataSource.getTopSkills(count));

  @override
  Future<Result<List<EventTarget>>> getRecentlyViewed({int limit = 10}) =>
      _guard(() async {
        final history = await remoteDataSource.getViewHistory(
          EnvConfig.currentUserId,
        );
        // The same vacancy opened three times should show up once.
        final seen = <String>{};
        return [
          for (final target in history)
            if (seen.add('${target.runtimeType}:${target.id}')) target,
        ].take(limit).toList();
      });

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
