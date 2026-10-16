import 'package:find_job_app/features/vacancies/data/models/SkillModel.dart';
import 'package:find_job_app/features/vacancies/data/models/CompanyModel.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';

class VacancyModel extends VacancyEntity {
  const VacancyModel({
    required super.id,
    required super.jobTitle,
    required super.salary,
    required super.description,
    required super.place,
    required super.grade,
    required super.format,
    required super.platform,
    required super.platformId,
    required super.siteHref,
    required super.company,
    required super.skills,
  });

  factory VacancyModel.fromJson(Map<String, dynamic> json) {
    return VacancyModel(
      id: json['id'] as int,
      jobTitle: json['job_title'] as String,
      salary: json['salary'] as int?,
      description: json['description'] as String,
      place: json['place'] as String?,
      grade: json['grade'] as int?,
      format: json['format'] as String?,
      platform: json['platform'] as String,
      platformId: json['platform_id'] as int,
      siteHref: json['site_href'] as String,
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
