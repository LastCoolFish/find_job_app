import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/analytics/data/models/EngagementModel.dart';
import 'package:find_job_app/features/analytics/data/models/SkillDemandModel.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';

abstract class AnalyticsRemoteDataSource {
  /// `GET /analytics/vacancies/{id}` or `GET /analytics/orders/{id}`
  Future<EngagementModel> getEngagement(EventTarget target);

  /// `POST /events`
  Future<void> sendEvent({
    required int userId,
    required EventType type,
    required EventTarget target,
    int? durationSeconds,
  });

  /// `GET /analytics/top-skills`: most requested skills.
  Future<List<SkillDemandModel>> getTopSkills(int count);

  /// `GET /users/{userId}/events?event_type=view_start`, newest first:
  /// what the user opened recently. May contain the same item many times.
  Future<List<EventTarget>> getViewHistory(int userId, {int limit = 50});
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;

  AnalyticsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<EngagementModel> getEngagement(EventTarget target) => _guard(() async {
    final path = switch (target) {
      VacancyTarget(:final id) => '/analytics/vacancies/$id',
      OrderTarget(:final id) => '/analytics/orders/$id',
    };
    final response = await apiClient.dio.get(path);
    return EngagementModel.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> sendEvent({
    required int userId,
    required EventType type,
    required EventTarget target,
    int? durationSeconds,
  }) => _guard(() async {
    await apiClient.dio.post(
      '/events',
      data: {
        'user_id': userId,
        'event_type': type.apiName,
        if (target is VacancyTarget) 'vacancy_id': target.id,
        if (target is OrderTarget) 'order_id': target.id,
        'duration_seconds': ?durationSeconds,
      },
    );
  });

  @override
  Future<List<SkillDemandModel>> getTopSkills(int count) => _guard(() async {
    final response = await apiClient.dio.get(
      '/analytics/top-skills',
      queryParameters: {'count': count},
    );
    return (response.data as List<dynamic>)
        .map((json) => SkillDemandModel.fromJson(json as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<List<EventTarget>> getViewHistory(int userId, {int limit = 50}) =>
      _guard(() async {
        final response = await apiClient.dio.get(
          '/users/$userId/events',
          queryParameters: {
            'event_type': EventType.viewStart.apiName,
            'order': 'desc',
            'limit': limit,
          },
        );
        return [
          for (final json in unwrapList(
            response.data,
          ).cast<Map<String, dynamic>>())
            if (json['vacancy_id'] != null)
              VacancyTarget(json['vacancy_id'] as int)
            else if (json['order_id'] != null)
              OrderTarget(json['order_id'] as int),
        ];
      });

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
