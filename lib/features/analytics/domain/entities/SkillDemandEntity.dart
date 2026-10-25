import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';

/// Matches `SkillDemandSchema`: a skill and how many vacancies ask for it.
class SkillDemandEntity extends Equatable {
  final SkillEntity skill;
  final int vacancyCount;

  const SkillDemandEntity({required this.skill, required this.vacancyCount});

  @override
  List<Object?> get props => [skill, vacancyCount];
}
