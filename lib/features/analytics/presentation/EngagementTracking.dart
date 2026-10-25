import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/domain/entities/EngagementEntity.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';

/// Shared logic for the vacancy and order details screens:
/// - sends "view_start" when the screen opens and "view_end" with the time
///   spent when it closes;
/// - sends "link_click" before opening the item on its website;
/// - loads the item's statistics into [engagement].
mixin EngagementTracking<T extends StatefulWidget> on State<T> {
  final AnalyticsRepository _analytics = sl<AnalyticsRepository>();
  final Stopwatch _viewTime = Stopwatch();

  /// Statistics shown on the screen. Loaded after "view_start" is sent,
  /// so the current view is already counted.
  late final Future<Result<EngagementEntity>> engagement;

  /// What this screen is about. Implemented by the screen.
  EventTarget get target;

  @override
  void initState() {
    super.initState();
    _viewTime.start();
    engagement = _analytics
        .track(EventType.viewStart, target)
        .then((_) => _analytics.getEngagement(target));
  }

  @override
  void dispose() {
    // Not awaited: the screen is already closing, the request just runs.
    _analytics.track(
      EventType.viewEnd,
      target,
      durationSeconds: _viewTime.elapsed.inSeconds,
    );
    super.dispose();
  }

  /// Records the click and opens [url] in the browser or the site's app.
  Future<void> openOnSite(String url) async {
    _analytics.track(EventType.linkClick, target);
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
