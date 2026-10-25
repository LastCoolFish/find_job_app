import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/vacancies/data/datasources/VacanciesRemoteDataSource.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';

class VacanciesRepositoryImpl implements VacanciesRepository {
  final VacanciesRemoteDataSource remoteDataSource;

  VacanciesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<VacancyEntity>>> getVacancies({
    VacancyFilters filters = const VacancyFilters(),
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final vacancies = await remoteDataSource.getVacancies(
        filters: filters,
        offset: offset,
        limit: limit,
      );
      return Success(vacancies);
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<List<String>>> getPlatforms() async {
    try {
      return Success(await remoteDataSource.getPlatforms());
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<VacancyEntity>> getVacancy(int id) async {
    try {
      return Success(await remoteDataSource.getVacancy(id));
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<List<VacancyEntity>>> getVacanciesBySkills(
    List<int> skillIds,
  ) async {
    try {
      return Success(await remoteDataSource.getVacanciesBySkills(skillIds));
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
