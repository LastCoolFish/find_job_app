import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:find_job_app/features/auth/domain/repositories/AuthRepository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio, this._storage);
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const _key = 'auth_tokens';
  Future<String?>? _refreshing;

  Future<AuthTokens?> _read() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    try {
      return AuthTokens.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on Object {
      await clear();
      return null;
    }
  }

  Future<void> _save(AuthTokens tokens) => _storage.write(
    key: _key,
    value: jsonEncode({
      'access_token': tokens.accessToken,
      'refresh_token': tokens.refreshToken,
    }),
  );

  @override
  Future<void> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _save(AuthTokens.fromJson(response.data!));
  }

  bool _expired(String token) {
    try {
      final parts = token.split('.');
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      return exp is! num || DateTime.now().millisecondsSinceEpoch >= exp * 1000;
    } on Object {
      return true;
    }
  }

  @override
  Future<String?> accessToken() async {
    final tokens = await _read();
    if (tokens == null) return null;
    return _expired(tokens.accessToken)
        ? refresh(rejectedToken: tokens.accessToken)
        : tokens.accessToken;
  }

  @override
  Future<String?> refresh({String? rejectedToken}) {
    final pending = _refreshing;
    if (pending != null) return pending;
    final operation = _refresh(rejectedToken);
    _refreshing = operation;
    return operation.whenComplete(() {
      if (identical(_refreshing, operation)) _refreshing = null;
    });
  }

  Future<String?> _refresh(String? rejectedToken) async {
    final tokens = await _read();
    if (tokens == null) return null;
    if (rejectedToken != null &&
        tokens.accessToken != rejectedToken &&
        !_expired(tokens.accessToken))
      return tokens.accessToken;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': tokens.refreshToken},
      );
      final updated = AuthTokens.fromJson(response.data!);
      await _save(updated);
      return updated.accessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        await clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final pending = _refreshing;
    if (pending != null) await pending;
    final tokens = await _read();
    if (tokens != null) {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refresh_token': tokens.refreshToken},
      );
    }
    await clear();
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
