import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';
import 'package:find_job_app/features/vacancies/data/models/SkillModel.dart';

class SkillDemandModel extends SkillDemandEntity {
  const SkillDemandModel({required super.skill, required super.vacancyCount});

  factory SkillDemandModel.fromJson(Map<String, dynamic> json) {
    return SkillDemandModel(
      skill: SkillModel.fromJson(json['skill'] as Map<String, dynamic>),
      vacancyCount: json['vacancy_count'] as int,
    );
  }
}
