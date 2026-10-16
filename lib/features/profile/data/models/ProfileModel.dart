import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/vacancies/data/models/SkillModel.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.name,
    required super.desiredSalary,
    required super.desiredFormat,
    required super.desiredGrade,
    required super.skills,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      name: json['name'] as String?,
      desiredSalary: json['desired_salary'] as int?,
      desiredFormat: json['desired_format'] as String?,
      desiredGrade: json['desired_grade'] as int?,
      skills: (json['skills'] as List<dynamic>)
          .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
