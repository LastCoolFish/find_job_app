import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/tracking/domain/entities/EventEntity.dart';

abstract class TrackingRepository {
  Future<Result<EventEntity>> createEvent({
    required int userId,
    required EventType eventType,
    int? vacancyId,
    int? orderId,
    int? durationSeconds,
    Map<String, dynamic>? payload,
  });

  Future<Result<Map<int, int>>> getVacanciesViews(List<int> vacancyIds);
  Future<Result<Map<int, int>>> getOrdersViews(List<int> orderIds);
}
