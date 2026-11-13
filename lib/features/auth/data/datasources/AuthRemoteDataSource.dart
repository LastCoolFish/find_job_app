import 'package:find_job_app/core/network/ApiClient.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _client.dio.post<void>(
      '/users',
      data: {'email': email, 'password': password},
    );
  }
}
