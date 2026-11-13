import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/profile/data/models/ProfileModel.dart';
import 'package:find_job_app/features/profile/data/models/UserModel.dart';
import 'package:find_job_app/features/vacancies/data/models/SkillModel.dart';

abstract class ProfileRemoteDataSource {
  /// `GET /profiles/by-user/{userId}`
  Future<ProfileModel> getProfileByUser(int userId);

  /// `GET /users/{userId}`
  Future<UserModel> getUser(int userId);

  Future<List<SkillModel>> getSkills();

  Future<ProfileModel> setSkills(int profileId, List<int> skillIds);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> getProfileByUser(int userId) =>
      _get('/profiles/by-user/$userId', ProfileModel.fromJson);

  @override
  Future<UserModel> getUser(int userId) =>
      _get('/users/$userId', UserModel.fromJson);

  @override
  Future<ProfileModel> setSkills(int profileId, List<int> skillIds) async {
    try {
      final response = await apiClient.dio.put(
        '/profiles/$profileId/skills',
        data: {'skill_ids': skillIds},
        options: Options(extra: {'requiresAuth': true}),
      );
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<List<SkillModel>> getSkills() async {
    try {
      final response = await apiClient.dio.get('/skills');
      return unwrapList(response.data)
          .map((item) => SkillModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await apiClient.dio.get(
        path,
        options: path.startsWith('/users/')
            ? Options(extra: {'requiresAuth': true})
            : null,
      );
      return parse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
