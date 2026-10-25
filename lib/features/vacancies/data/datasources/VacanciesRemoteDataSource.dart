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

  /// Distinct platform codes, e.g. ['habr', 'hh'].
  Future<List<String>> getPlatforms();

  /// `GET /vacancies/{id}`
  Future<VacancyModel> getVacancy(int id);

  /// `GET /vacancies/by-skills`: vacancies that have every one of [skillIds].
  Future<List<VacancyModel>> getVacanciesBySkills(List<int> skillIds);
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

  @override
  Future<List<String>> getPlatforms() async {
    try {
      final response = await apiClient.dio.get('/vacancies/platforms');
      return (response.data as List<dynamic>).cast<String>();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<VacancyModel> getVacancy(int id) async {
    try {
      final response = await apiClient.dio.get('/vacancies/$id');
      return VacancyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<List<VacancyModel>> getVacanciesBySkills(List<int> skillIds) async {
    try {
      final response = await apiClient.dio.get(
        '/vacancies/by-skills',
        queryParameters: {'skills_id': skillIds},
      );
      return unwrapList(response.data)
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
