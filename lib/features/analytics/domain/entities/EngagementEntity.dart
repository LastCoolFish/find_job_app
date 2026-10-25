import 'package:equatable/equatable.dart';

/// Matches `EngagementAnalyticsSchema`: how users interact with one
/// vacancy or order.
class EngagementEntity extends Equatable {
  final int totalViews;
  final int linkClicks;

  /// linkClicks / totalViews, from 0 to 1.
  final double ctr;

  /// Average time on the details screen, in seconds. Null if never viewed.
  final double? avgViewDurationSeconds;

  const EngagementEntity({
    required this.totalViews,
    required this.linkClicks,
    required this.ctr,
    required this.avgViewDurationSeconds,
  });

  @override
  List<Object?> get props => [
    totalViews,
    linkClicks,
    ctr,
    avgViewDurationSeconds,
  ];
}
