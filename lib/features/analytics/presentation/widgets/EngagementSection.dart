import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/InfoRow.dart';
import 'package:find_job_app/core/widgets/SectionCard.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';

/// "Статистика" block on the details screens: views, clicks to the site,
/// CTR and average viewing time.
class EngagementSection extends StatelessWidget {
  final Future<Result<EngagementEntity>> engagement;

  const EngagementSection({super.key, required this.engagement});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Статистика',
      child: FutureBuilder<Result<EngagementEntity>>(
        future: engagement,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final error = Text(
            'Не удалось загрузить статистику',
            style: TextStyle(color: AppColors.muted),
          );
          final result = snapshot.data;
          if (result == null) return error;

          return result.when(
            success: (e) => Column(
              children: [
                InfoRow(
                  icon: Symbols.visibility,
                  label: 'Просмотры',
                  value: '${e.totalViews}',
                ),
                InfoRow(
                  icon: Symbols.open_in_new,
                  label: 'Переходы на сайт',
                  value: '${e.linkClicks}',
                ),
                InfoRow(
                  icon: Symbols.percent,
                  label: 'Конверсия в переход',
                  value: '${(e.ctr * 100).toStringAsFixed(1)} %',
                ),
                InfoRow(
                  icon: Symbols.timer,
                  label: 'Среднее время просмотра',
                  value: _formatDuration(e.avgViewDurationSeconds),
                ),
              ],
            ),
            failure: (_) => error,
          );
        },
      ),
    );
  }

  /// 75.4 -> "1 мин 15 с", 12.0 -> "12 с", null -> null ("Не указано").
  static String? _formatDuration(double? seconds) {
    if (seconds == null) return null;
    final total = seconds.round();
    final minutes = total ~/ 60;
    final rest = total % 60;
    return minutes == 0 ? '$rest с' : '$minutes мин $rest с';
  }
}
