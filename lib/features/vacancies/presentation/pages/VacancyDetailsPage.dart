import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';
import 'package:find_job_app/core/widgets/OpenOnSiteBar.dart';
import 'package:find_job_app/core/widgets/SectionCard.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/presentation/EngagementTracking.dart';
import 'package:find_job_app/features/analytics/presentation/widgets/EngagementSection.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

/// Full vacancy: company, salary, tags, full description, all skills and
/// statistics. Opened with Navigator.push from the vacancies list, so going
/// back returns to the same list without reloading it.
class VacancyDetailsPage extends StatefulWidget {
  final VacancyEntity vacancy;

  const VacancyDetailsPage({super.key, required this.vacancy});

  @override
  State<VacancyDetailsPage> createState() => _VacancyDetailsPageState();
}

class _VacancyDetailsPageState extends State<VacancyDetailsPage>
    with EngagementTracking {
  @override
  EventTarget get target => VacancyTarget(widget.vacancy.id);

  @override
  Widget build(BuildContext context) {
    final vacancy = widget.vacancy;
    final textTheme = Theme.of(context).textTheme;
    final grade = vacancy.grade;
    final format = VacancyCard.formatLabel(vacancy.format);
    final description = vacancy.description.trim();

    return Scaffold(
      appBar: const FindJobAppBar(title: 'Вакансия', icon: Symbols.work),
      bottomNavigationBar: OpenOnSiteBar(onPressed: () => openOnSite(vacancy.siteHref)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: vacancy.company.name, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vacancy.company.name,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (vacancy.company.accreditation) ...[
                                const SizedBox(width: 4),
                                Icon(Symbols.verified,
                                    size: 18, color: AppColors.accent, fill: 1),
                              ],
                            ],
                          ),
                          Text(vacancy.platform,
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  vacancy.jobTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (vacancy.salary != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(vacancy.salary!),
                    style: TextStyle(
                      color: AppColors.salary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (grade != null && grade >= 0 && grade < VacancyCard.grades.length)
                      Tag(
                        label: VacancyCard.grades[grade],
                        icon: Symbols.stacks,
                        background: AppColors.tertiary,
                        foreground: AppColors.ink,
                      ),
                    if (format != null) Tag(label: format, icon: Symbols.work),
                    // Full address here, the card only shows the city.
                    if (vacancy.place != null && vacancy.place!.isNotEmpty)
                      Tag(label: vacancy.place!, icon: Symbols.location_on),
                  ],
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Описание',
            child: Text(
              description.isEmpty ? 'Описание не указано' : description,
              style: textTheme.bodyLarge?.copyWith(
                color: description.isEmpty ? AppColors.muted : AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
          if (vacancy.skills.isNotEmpty)
            SectionCard(
              title: 'Навыки',
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final skill in vacancy.skills) Tag(label: skill.name)],
              ),
            ),
          EngagementSection(engagement: engagement),
        ],
      ),
    );
  }
}
