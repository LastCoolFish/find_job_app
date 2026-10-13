import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/skills/domain/entities/SkillEntity.dart';

/// Matches `SkillDemandSchema` (from `/analytics/top-skills`) — a computed
/// ranking, not a mirror of a stored table.
class TopSkillEntity extends Equatable {
  final SkillEntity skill;
  final int vacancyCount;

  const TopSkillEntity({required this.skill, required this.vacancyCount});

  @override
  List<Object?> get props => [skill, vacancyCount];
}
