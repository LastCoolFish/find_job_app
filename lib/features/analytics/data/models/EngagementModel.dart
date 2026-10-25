import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';

class EngagementModel extends EngagementEntity {
  const EngagementModel({
    required super.totalViews,
    required super.linkClicks,
    required super.ctr,
    required super.avgViewDurationSeconds,
  });

  factory EngagementModel.fromJson(Map<String, dynamic> json) {
    return EngagementModel(
      totalViews: json['total_views'] as int,
      linkClicks: json['link_clicks'] as int,
      ctr: (json['ctr'] as num).toDouble(),
      avgViewDurationSeconds: (json['avg_view_duration'] as num?)?.toDouble(),
    );
  }
}
