import 'package:find_job_app/features/skills/domain/entities/SkillEntity.dart';

/// Maps 1:1 to `SkillOutSchema` from the FastAPI backend.
class SkillModel extends SkillEntity {
  const SkillModel({required super.id, required super.name});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
