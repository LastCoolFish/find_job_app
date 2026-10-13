import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

/// Small rounded label with an optional leading icon (grade, work format,
/// skill, etc.).
class Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  // Null means "use the active palette" (AppColors).
  final Color? background;
  final Color? foreground;

  const Tag({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground ?? AppColors.ink),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.ink, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
