import 'package:dio/dio.dart';
import 'package:find_job_app/core/error/Exceptions.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/profile/data/models/ProfileModel.dart';
import 'package:find_job_app/features/profile/data/models/UserModel.dart';

abstract class ProfileRemoteDataSource {
  /// `GET /profiles/by-user/{userId}`
  Future<ProfileModel> getProfileByUser(int userId);

  /// `GET /users/{userId}`
  Future<UserModel> getUser(int userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> getProfileByUser(int userId) =>
      _get('/profiles/by-user/$userId', ProfileModel.fromJson);

  @override
  Future<UserModel> getUser(int userId) => _get('/users/$userId', UserModel.fromJson);

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await apiClient.dio.get(path);
      return parse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
