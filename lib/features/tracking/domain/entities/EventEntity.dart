import 'package:equatable/equatable.dart';

enum EventType { viewStart, viewEnd, linkClick, search }

EventType eventTypeFromString(String value) {
  switch (value) {
    case 'view_start':
      return EventType.viewStart;
    case 'view_end':
      return EventType.viewEnd;
    case 'link_click':
      return EventType.linkClick;
    case 'search':
      return EventType.search;
    default:
      throw ArgumentError('Unknown event type: $value');
  }
}

String eventTypeToJson(EventType type) {
  switch (type) {
    case EventType.viewStart:
      return 'view_start';
    case EventType.viewEnd:
      return 'view_end';
    case EventType.linkClick:
      return 'link_click';
    case EventType.search:
      return 'search';
  }
}

/// Matches `EventOutSchema` — a user interaction (view, click, search) used
/// to compute engagement analytics.
class EventEntity extends Equatable {
  final int id;
  final int userId;
  final EventType eventType;
  final int? vacancyId;
  final int? orderId;
  final int? durationSeconds;
  final Map<String, dynamic>? payload;
  final DateTime occurredAt;

  const EventEntity({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.vacancyId,
    required this.orderId,
    required this.durationSeconds,
    required this.payload,
    required this.occurredAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, eventType, vacancyId, orderId, durationSeconds, payload, occurredAt];
}
