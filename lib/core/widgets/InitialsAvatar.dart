import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

/// Rounded square with the first letters of a name. Used instead of a logo,
/// since the API has no company/customer images.
class InitialsAvatar extends StatelessWidget {
  final String name;

  const InitialsAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // Skip separators like "-" in "БФТ - Холдинг".
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.startsWith(RegExp(r'[\p{L}\p{N}]', unicode: true)));
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
