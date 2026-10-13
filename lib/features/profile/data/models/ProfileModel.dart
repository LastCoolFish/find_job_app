import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.username,
    required super.desiredSalary,
    required super.desiredFormat,
    required super.desiredGrade,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String?,
      username: json['username'] as String,
      desiredSalary: json['desired_salary'] as int?,
      desiredFormat: json['desired_format'] as String?,
      desiredGrade: json['desired_grade'] as int?,
    );
  }
}
