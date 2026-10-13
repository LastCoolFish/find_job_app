import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';

abstract class ProfileRepository {
  Future<Result<List<ProfileEntity>>> getProfiles();
  Future<Result<List<UserEntity>>> getUsers();
}
