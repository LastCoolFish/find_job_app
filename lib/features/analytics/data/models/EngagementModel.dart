import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';

class EngagementModel extends EngagementEntity {
  const EngagementModel({
    required super.avgViewDuration,
    required super.linkClicks,
    required super.totalViews,
    required super.ctr,
  });

  factory EngagementModel.fromJson(Map<String, dynamic> json) {
    return EngagementModel(
      avgViewDuration: (json['avg_view_duration'] as num?)?.toDouble(),
      linkClicks: json['link_clicks'] as int,
      totalViews: json['total_views'] as int,
      ctr: (json['ctr'] as num).toDouble(),
    );
  }
}
