import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/TopCompanyEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/TopSkillEntity.dart';

abstract class AnalyticsRepository {
  Future<Result<List<TopSkillEntity>>> getTopSkills({int count = 5});
  Future<Result<List<TopCompanyEntity>>> getTopCompanies({int count = 5});
  Future<Result<EngagementEntity>> getVacancyAnalytics(int vacancyId);
  Future<Result<EngagementEntity>> getOrderAnalytics(int orderId);
}
