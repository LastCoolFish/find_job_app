import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/skills/data/datasources/SkillsRemoteDataSource.dart';
import 'package:find_job_app/features/skills/domain/entities/SkillEntity.dart';
import 'package:find_job_app/features/skills/domain/repositories/SkillsRepository.dart';

class SkillsRepositoryImpl implements SkillsRepository {
  final SkillsRemoteDataSource remoteDataSource;

  SkillsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<SkillEntity>>> getSkills() async {
    try {
      final skills = await remoteDataSource.getSkills();
      return Success(skills);
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
