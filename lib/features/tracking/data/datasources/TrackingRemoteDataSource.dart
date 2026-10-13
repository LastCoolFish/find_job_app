import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/tracking/data/models/EventModel.dart';
import 'package:find_job_app/features/tracking/domain/entities/EventEntity.dart';

abstract class TrackingRemoteDataSource {
  Future<EventModel> createEvent({
    required int userId,
    required EventType eventType,
    int? vacancyId,
    int? orderId,
    int? durationSeconds,
    Map<String, dynamic>? payload,
  });

  Future<Map<int, int>> getVacanciesViews(List<int> vacancyIds);
  Future<Map<int, int>> getOrdersViews(List<int> orderIds);
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final ApiClient apiClient;

  TrackingRemoteDataSourceImpl(this.apiClient);

  @override
  Future<EventModel> createEvent({
    required int userId,
    required EventType eventType,
    int? vacancyId,
    int? orderId,
    int? durationSeconds,
    Map<String, dynamic>? payload,
  }) {
    return _guard(() async {
      final response = await apiClient.dio.post('/events', data: {
        'user_id': userId,
        'event_type': eventTypeToJson(eventType),
        'vacancy_id': vacancyId,
        'order_id': orderId,
        'duration_seconds': durationSeconds,
        'payload': payload,
      });
      return EventModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Map<int, int>> getVacanciesViews(List<int> vacancyIds) {
    return _getViews('/events/vacancies-views', 'vacancies_ids', vacancyIds);
  }

  @override
  Future<Map<int, int>> getOrdersViews(List<int> orderIds) {
    return _getViews('/events/orders-views', 'order_ids', orderIds);
  }

  Future<Map<int, int>> _getViews(String path, String param, List<int> ids) {
    return _guard(() async {
      final response = await apiClient.dio.get(path, queryParameters: {param: ids});
      final data = response.data as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(int.parse(key), value as int));
    });
  }

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
