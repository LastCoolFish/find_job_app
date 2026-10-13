import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/skills/domain/entities/SkillEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/CompanyEntity.dart';

/// Matches `VacancyOutSchema` from the FastAPI backend.
class VacancyEntity extends Equatable {
  final int id;
  final String jobTitle;
  final int? salary;
  final String description;
  final String? place;
  final int? grade;
  final String? format;
  final String platform;
  final int platformId;
  final String siteHref;
  final CompanyEntity company;
  final List<SkillEntity> skills;

  const VacancyEntity({
    required this.id,
    required this.jobTitle,
    required this.salary,
    required this.description,
    required this.place,
    required this.grade,
    required this.format,
    required this.platform,
    required this.platformId,
    required this.siteHref,
    required this.company,
    required this.skills,
  });

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        salary,
        description,
        place,
        grade,
        format,
        platform,
        platformId,
        siteHref,
        company,
        skills,
      ];
}
