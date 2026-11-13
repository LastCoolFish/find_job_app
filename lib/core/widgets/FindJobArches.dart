import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

class FindJobArches extends StatelessWidget {
  const FindJobArches({
    super.key,
    this.progress,
    this.showSwipeArrow = false,
    this.showDots = true,
  });

  final Animation<double>? progress;
  final bool showSwipeArrow;
  final bool showDots;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _ArchesPainter(progress, showSwipeArrow, showDots),
    child: const SizedBox.expand(),
  );
}

class _ArchesPainter extends CustomPainter {
  _ArchesPainter(this.progress, this.showSwipeArrow, this.showDots)
    : super(repaint: progress);

  final Animation<double>? progress;
  final bool showSwipeArrow;
  final bool showDots;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width * .43, size.height * .52);
    final center = Offset(size.width / 2, radius + size.height * .08);
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: .48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final phase = (1 - math.cos(2 * math.pi * (progress?.value ?? .27))) / 2;

    for (var index = 0; index < 6; index++) {
      final r = radius * (1 - index * .145);
      final path = Path()
        ..moveTo(center.dx - r, size.height * .96)
        ..lineTo(center.dx - r, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          math.pi,
          math.pi,
          false,
        )
        ..lineTo(center.dx + r, size.height * .96);
      canvas.drawPath(path, paint);
      if (showDots &&
          !showSwipeArrow &&
          (index == 0 || (index == 3 && progress != null))) {
        final metric = path.computeMetrics().first;
        final fraction = index == 0 ? phase : 1 - phase;
        final dot = metric.getTangentForOffset(
          metric.length * (.10 + .80 * fraction),
        )!;
        canvas.drawCircle(
          dot.position,
          index == 0 ? 9 : 7,
          Paint()..color = AppColors.secondary,
        );
        canvas.drawCircle(
          dot.position,
          index == 0 ? 5 : 4,
          Paint()..color = AppColors.primary,
        );
      }
    }
    if (showSwipeArrow) {
      final origin = Offset(center.dx, size.height * .67);
      canvas.drawCircle(origin, 19, Paint()..color = AppColors.primary);
      final arrow = Path()
        ..moveTo(origin.dx - 8, origin.dy + 2)
        ..lineTo(origin.dx, origin.dy - 7)
        ..lineTo(origin.dx + 8, origin.dy + 2)
        ..moveTo(origin.dx, origin.dy - 7)
        ..lineTo(origin.dx, origin.dy + 9);
      canvas.drawPath(
        arrow,
        paint
          ..color = Colors.white
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(_ArchesPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      showSwipeArrow != oldDelegate.showSwipeArrow ||
      showDots != oldDelegate.showDots;
}
