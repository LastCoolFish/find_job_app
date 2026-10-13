import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/profile/data/datasources/ProfileRemoteDataSource.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<ProfileEntity>>> getProfiles() => _guard(remoteDataSource.getProfiles);

  @override
  Future<Result<List<UserEntity>>> getUsers() => _guard(remoteDataSource.getUsers);

  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
