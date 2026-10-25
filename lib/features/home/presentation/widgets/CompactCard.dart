import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';

/// Small fixed-width card for the horizontal lists on the home screen.
/// Works for both vacancies (company + salary) and orders (customer + price).
class CompactCard extends StatelessWidget {
  final String author;
  final String title;
  final String platform;
  final int? money;
  final VoidCallback onTap;

  const CompactCard({
    super.key,
    required this.author,
    required this.title,
    required this.platform,
    required this.money,
    required this.onTap,
  });

  static const width = 240.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: author, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(platform, style: textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  money == null ? 'Оплата не указана' : formatMoney(money!),
                  style: money == null
                      ? textTheme.bodySmall?.copyWith(color: AppColors.muted)
                      : textTheme.titleMedium?.copyWith(
                          color: AppColors.salary,
                          fontWeight: FontWeight.w800,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
