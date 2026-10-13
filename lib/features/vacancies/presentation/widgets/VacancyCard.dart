import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/vacancies/domain/entities/CompanyEntity.dart';
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
  static const _grades = ['Intern', 'Junior', 'Middle', 'Senior', 'Lead'];

  static Color get _cardColor => AppColors.card;
  static Color get _textColor => AppColors.ink;
  static Color get _mutedColor => AppColors.muted;
  static Color get _salaryColor => AppColors.salary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final grade = vacancy.grade;
    final format = _formatLabel(vacancy.format);
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
                _CompanyLogo(company: vacancy.company),
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
                            _platformLabel(vacancy.platform),
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
                          _formatSalary(vacancy.salary!),
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
                            if (grade != null && grade >= 0 && grade < _grades.length)
                              Tag(
                                label: _grades[grade],
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
  static String? _formatLabel(String? raw) {
    if (raw == null) return null;
    final f = raw.toLowerCase();
    if (f.contains('удал')) return 'Можно удалённо';
    if (f.contains('гибрид')) return 'Гибрид';
    if (f.contains('мест')) return 'В офисе';
    return raw;
  }

  static String _platformLabel(String platform) => switch (platform) {
        'hh' => 'hh.ru',
        'habr' => 'Хабр Карьера',
        _ => platform,
      };

  static String _formatSalary(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer ₽';
  }
}

/// API has no company logos, so draw the company initials instead.
class _CompanyLogo extends StatelessWidget {
  final CompanyEntity company;

  const _CompanyLogo({required this.company});

  @override
  Widget build(BuildContext context) {
    // Skip separators like "-" in "БФТ - Холдинг".
    final words = company.name
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
