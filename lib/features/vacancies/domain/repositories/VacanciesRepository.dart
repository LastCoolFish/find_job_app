import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';

abstract class VacanciesRepository {
  Future<Result<List<VacancyEntity>>> getVacancies({
    VacancyFilters filters = const VacancyFilters(),
    int offset = 0,
    int limit = 20,
  });

  /// Distinct platform codes, e.g. ['habr', 'hh'].
  Future<Result<List<String>>> getPlatforms();
}
