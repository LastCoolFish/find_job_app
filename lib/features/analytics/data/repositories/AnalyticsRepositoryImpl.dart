import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/data/datasources/AnalyticsRemoteDataSource.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/TopCompanyEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/TopSkillEntity.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<TopSkillEntity>>> getTopSkills({int count = 5}) =>
      _guard(() => remoteDataSource.getTopSkills(count: count));

  @override
  Future<Result<List<TopCompanyEntity>>> getTopCompanies({int count = 5}) =>
      _guard(() => remoteDataSource.getTopCompanies(count: count));

  @override
  Future<Result<EngagementEntity>> getVacancyAnalytics(int vacancyId) =>
      _guard(() => remoteDataSource.getVacancyAnalytics(vacancyId));

  @override
  Future<Result<EngagementEntity>> getOrderAnalytics(int orderId) =>
      _guard(() => remoteDataSource.getOrderAnalytics(orderId));

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
