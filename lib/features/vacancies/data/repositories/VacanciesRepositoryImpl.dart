import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/error/Failures.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/vacancies/data/datasources/VacanciesRemoteDataSource.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';

import '../../../../core/utils/Enums.dart';

class VacanciesRepositoryImpl implements VacanciesRepository {
  final VacanciesRemoteDataSource remoteDataSource;

  VacanciesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<VacancyEntity>>> getVacancies({
    VacanciesSortBy? sortBy,
    int offset = 0,
    int limit = 20,
    Order order = Order.asc,
  }) async {
    try {
      final vacancies = await remoteDataSource.getVacancies(
        sortBy: sortBy,
        offset: offset,
        limit: limit,
        order: order,
      );
      return Success(vacancies);
    } on NetworkException catch (e) {
      return Failed(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Failed(ServerFailure(e.message));
    }
  }
}
