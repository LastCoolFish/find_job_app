import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';

abstract class AnalyticsRepository {
  Future<Result<EngagementEntity>> getEngagement(EventTarget target);

  /// Records a user action for [EnvConfig.currentUserId]. Fire-and-forget:
  /// a failed event must never break the screen, so errors are swallowed.
  Future<void> track(
    EventType type,
    EventTarget target, {
    int? durationSeconds,
  });

  Future<Result<List<SkillDemandEntity>>> getTopSkills(int count);

  /// Vacancies and orders the current user opened recently, newest first,
  /// without repeats, at most [limit] of them.
  Future<Result<List<EventTarget>>> getRecentlyViewed({int limit = 10});
}
