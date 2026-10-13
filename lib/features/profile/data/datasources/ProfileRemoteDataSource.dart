import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/profile/data/models/ProfileModel.dart';
import 'package:find_job_app/features/profile/data/models/UserModel.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> getProfiles();
  Future<List<UserModel>> getUsers();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProfileModel>> getProfiles() {
    return _get('/profiles', ProfileModel.fromJson);
  }

  @override
  Future<List<UserModel>> getUsers() {
    return _get('/users', UserModel.fromJson);
  }

  Future<List<T>> _get<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await apiClient.dio.get(path);
      final data = response.data as List<dynamic>;
      return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
