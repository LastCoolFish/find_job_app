import 'package:equatable/equatable.dart';

/// Matches `EngagementAnalyticsSchema` (from `/analytics/vacancies/{id}` and
/// `/analytics/orders/{id}`) — a computed metric, not a mirror of a stored table.
class EngagementEntity extends Equatable {
  final double? avgViewDuration;
  final int linkClicks;
  final int totalViews;
  final double ctr;

  const EngagementEntity({
    required this.avgViewDuration,
    required this.linkClicks,
    required this.totalViews,
    required this.ctr,
  });

  @override
  List<Object?> get props => [avgViewDuration, linkClicks, totalViews, ctr];
}
