import 'package:find_job_app/features/tracking/domain/entities/EventEntity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.userId,
    required super.eventType,
    required super.vacancyId,
    required super.orderId,
    required super.durationSeconds,
    required super.payload,
    required super.occurredAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      eventType: eventTypeFromString(json['event_type'] as String),
      vacancyId: json['vacancy_id'] as int?,
      orderId: json['order_id'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      payload: json['payload'] as Map<String, dynamic>?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );
  }
}
