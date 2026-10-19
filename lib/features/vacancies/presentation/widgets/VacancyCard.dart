import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';

class VacancyCard extends StatelessWidget {
  final VacancyEntity vacancy;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const VacancyCard({
    super.key,
    required this.vacancy,
    this.onTap,
    this.onDetails,
    this.onBookmark,
    this.isBookmarked = false,
  });

  static const _maxSkills = 4;

  // API stores grade as 0..4.
  static const grades = ['Intern', 'Junior', 'Middle', 'Senior', 'Lead'];

  static Color get _cardColor => AppColors.card;
  static Color get _textColor => AppColors.ink;
  static Color get _mutedColor => AppColors.muted;
  static Color get _salaryColor => AppColors.salary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final grade = vacancy.grade;
    final format = formatLabel(vacancy.format);
    final place = vacancy.place?.split(',').first.trim();
    final shownSkills = vacancy.skills.take(_maxSkills);
    final hiddenSkills = vacancy.skills.length - _maxSkills;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(name: vacancy.company.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    vacancy.company.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(color: _textColor),
                                  ),
                                ),
                                if (vacancy.company.accreditation) ...[
                                  const SizedBox(width: 4),
                                  Icon(Symbols.verified, size: 16, color: AppColors.accent, fill: 1),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vacancy.platform,
                            style: textTheme.bodySmall?.copyWith(color: _mutedColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vacancy.jobTitle,
                        style: textTheme.titleLarge?.copyWith(
                          color: _textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (vacancy.salary != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          formatMoney(vacancy.salary!),
                          style: textTheme.titleMedium?.copyWith(
                              color: _salaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 24
                          ),
                        ),
                      ],

                      if (grade != null || format != null || place != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (grade != null && grade >= 0 && grade < grades.length)
                              Tag(
                                label: grades[grade],
                                icon: Symbols.stacks,
                                background: AppColors.tertiary,
                                foreground: AppColors.ink,
                              ),
                            if (format != null)
                              Tag(label: format, icon: Symbols.work),
                            if (place != null && place.isNotEmpty)
                              Tag(label: place, icon: Symbols.location_on),
                          ],
                        ),
                      ],
                      if (vacancy.skills.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final skill in shownSkills) Tag(label: skill.name),
                            if (hiddenSkills > 0) Tag(label: '+$hiddenSkills'),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          FilledButton(
                            onPressed: onDetails,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Подробнее'),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: onBookmark,
                            tooltip: 'В избранное',
                            color: _textColor,
                            disabledColor: _textColor,
                            icon: Icon(Symbols.bookmark, fill: isBookmarked ? 1 : 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Raw formats are long free-text strings ("на месте работодателя, удалённо
  /// или гибрид"), so collapse them to the most remote-friendly option.
  static String? formatLabel(String? raw) {
    if (raw == null) return null;
    final f = raw.toLowerCase();
    if (f.contains('удал')) return 'Можно удалённо';
    if (f.contains('гибрид')) return 'Гибрид';
    if (f.contains('мест')) return 'В офисе';
    return raw;
  }
}
