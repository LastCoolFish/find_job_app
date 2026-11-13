import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity>> getProfileByUser(int userId);

  Future<Result<UserEntity>> getUser(int userId);

  Future<Result<List<SkillEntity>>> getSkills();

  Future<Result<ProfileEntity>> setSkills(int profileId, List<int> skillIds);
}
