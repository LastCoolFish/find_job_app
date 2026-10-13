import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/analytics/data/models/EngagementModel.dart';
import 'package:find_job_app/features/analytics/data/models/TopCompanyModel.dart';
import 'package:find_job_app/features/analytics/data/models/TopSkillModel.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<TopSkillModel>> getTopSkills({int count});
  Future<List<TopCompanyModel>> getTopCompanies({int count});
  Future<EngagementModel> getVacancyAnalytics(int vacancyId);
  Future<EngagementModel> getOrderAnalytics(int orderId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;

  AnalyticsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TopSkillModel>> getTopSkills({int count = 5}) {
    return _guard(() async {
      final response = await apiClient.dio
          .get('/analytics/top-skills', queryParameters: {'count': count});
      final data = response.data as List<dynamic>;
      return data
          .map((json) => TopSkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<TopCompanyModel>> getTopCompanies({int count = 5}) {
    return _guard(() async {
      final response = await apiClient.dio
          .get('/analytics/top-companies', queryParameters: {'count': count});
      final data = response.data as List<dynamic>;
      return data
          .map((json) => TopCompanyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<EngagementModel> getVacancyAnalytics(int vacancyId) {
    return _guard(() async {
      final response = await apiClient.dio.get('/analytics/vacancies/$vacancyId');
      return EngagementModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<EngagementModel> getOrderAnalytics(int orderId) {
    return _guard(() async {
      final response = await apiClient.dio.get('/analytics/orders/$orderId');
      return EngagementModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
