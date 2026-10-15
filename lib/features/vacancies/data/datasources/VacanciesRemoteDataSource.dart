import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/vacancies/data/models/VacancyModel.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';

abstract class VacanciesRemoteDataSource {
  Future<List<VacancyModel>> getVacancies({
    VacancyFilters filters = const VacancyFilters(),
    int offset = 0,
    int limit = 20,
  });
}

class VacanciesRemoteDataSourceImpl implements VacanciesRemoteDataSource {
  final ApiClient apiClient;

  VacanciesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<VacancyModel>> getVacancies({
    VacancyFilters filters = const VacancyFilters(),
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // /search with no filters returns the same as /vacancies, so one
      // endpoint covers both cases.
      final response = await apiClient.dio.get(
        '/vacancies/search',
        queryParameters: {
          ...filters.toQueryParameters(),
          'offset': offset,
          'limit': limit,
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
