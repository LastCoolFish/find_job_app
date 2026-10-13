import 'package:find_job_app/features/analytics/domain/entities/TopSkillEntity.dart';
import 'package:find_job_app/features/skills/data/models/SkillModel.dart';

class TopSkillModel extends TopSkillEntity {
  const TopSkillModel({required super.skill, required super.vacancyCount});

  factory TopSkillModel.fromJson(Map<String, dynamic> json) {
    return TopSkillModel(
      skill: SkillModel.fromJson(json['skill'] as Map<String, dynamic>),
      vacancyCount: json['vacancy_count'] as int,
    );
  }
}
