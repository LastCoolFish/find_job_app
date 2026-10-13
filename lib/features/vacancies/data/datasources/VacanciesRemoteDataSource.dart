import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/vacancies/data/models/VacancyModel.dart';

import '../../../../core/utils/Enums.dart';

abstract class VacanciesRemoteDataSource {
  Future<List<VacancyModel>> getVacancies({
    VacanciesSortBy? sortBy,
    int offset = 0,
    int limit = 20,
    Order order = Order.asc,
  });
}

class VacanciesRemoteDataSourceImpl implements VacanciesRemoteDataSource {
  final ApiClient apiClient;

  VacanciesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<VacancyModel>> getVacancies({
    VacanciesSortBy? sortBy,
    int offset = 0,
    int limit = 20,
    Order order = Order.asc,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/vacancies',
        queryParameters: {
          "offset": offset,
          "limit": limit,
          if (sortBy != null) "sort_by": sortBy.name,
          "order": order.name,
        },
      );
      final data = unwrapList(response.data);
      return data
          .map((json) => VacancyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
