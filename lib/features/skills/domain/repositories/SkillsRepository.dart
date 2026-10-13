import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/skills/domain/entities/SkillEntity.dart';

abstract class SkillsRepository {
  Future<Result<List<SkillEntity>>> getSkills();
}
