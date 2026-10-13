import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/skills/data/models/SkillModel.dart';

abstract class SkillsRemoteDataSource {
  Future<List<SkillModel>> getSkills();
}

class SkillsRemoteDataSourceImpl implements SkillsRemoteDataSource {
  final ApiClient apiClient;

  SkillsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SkillModel>> getSkills() async {
    try {
      final response = await apiClient.dio.get('/skills');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
