import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';

import '../../../../core/utils/Enums.dart';

abstract class VacanciesRepository {
  Future<Result<List<VacancyEntity>>> getVacancies({
    VacanciesSortBy? sortBy,
    int offset = 0,
    int limit = 20,
    Order order = Order.asc,
  });
}
