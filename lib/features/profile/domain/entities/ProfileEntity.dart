import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';

/// Matches `ProfileOutSchema`: what the job seeker is looking for.
class ProfileEntity extends Equatable {
  final int id;
  final int userId;
  final String username; // nickname
  final String? name;
  final int? desiredSalary;
  final String? desiredFormat;
  final int? desiredGrade; // 0..4, same scale as vacancies
  final List<SkillEntity> skills;

  const ProfileEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.name,
    required this.desiredSalary,
    required this.desiredFormat,
    required this.desiredGrade,
    required this.skills,
  });

  @override
  List<Object?> get props =>
      [id, userId, username, name, desiredSalary, desiredFormat, desiredGrade, skills];
}
