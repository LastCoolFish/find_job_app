import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/ListingCard.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';

class VacancyCard extends StatelessWidget {
  const VacancyCard({
    super.key,
    required this.vacancy,
    this.onTap,
    this.onDetails,
    this.onBookmark,
    this.isBookmarked = false,
  });

  final VacancyEntity vacancy;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  static const grades = ['Intern', 'Junior', 'Middle', 'Senior', 'Lead'];
  static const _maxSkills = 4;

  @override
  Widget build(BuildContext context) {
    final grade = vacancy.grade;
    final format = formatLabel(vacancy.format);
    final place = vacancy.place?.split(',').first.trim();
    final salary = vacancy.salary;
    final hiddenSkills = vacancy.skills.length - _maxSkills;
    final tags = [
      if (grade != null && grade >= 0 && grade < grades.length)
        Tag(label: grades[grade], background: AppColors.secondary),
      if (format != null && format.isNotEmpty) Tag(label: format),
      if (place != null && place.isNotEmpty) Tag(label: place),
      for (final skill in vacancy.skills.take(_maxSkills))
        Tag(label: skill.name),
      if (hiddenSkills > 0) Tag(label: '+$hiddenSkills'),
    ];

    return ListingCard(
      author: vacancy.company.name,
      source: switch (vacancy.platform.toLowerCase()) {
        'habr' => 'Хабр Карьера',
        _ => vacancy.platform,
      },
      title: vacancy.jobTitle,
      titleBesideAuthor: true,
      verified: vacancy.company.accreditation,
      onTap: onTap,
      onDetails: onDetails,
      trailing: IconButton(
        onPressed: onBookmark,
        tooltip: 'В избранное',
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: 19,
        ),
      ),
      children: [
        if (salary != null) ...[
          const SizedBox(height: 8),
          Text(
            formatMoney(salary),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.salary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: tags),
        ],
      ],
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
