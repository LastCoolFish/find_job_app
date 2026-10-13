import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

/// Small rounded label with an optional leading icon (grade, work format,
/// skill, etc.).
class Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  static const defaultBackground = AppColors.cream;
  static const defaultForeground = AppColors.ink;

  const Tag({
    super.key,
    required this.label,
    this.icon,
    this.background = defaultBackground,
    this.foreground = defaultForeground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: defaultForeground, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
