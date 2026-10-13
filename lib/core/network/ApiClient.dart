import 'package:dio/dio.dart';
import 'package:find_job_app/core/config/EnvConfig.dart';

/// Thin wrapper around Dio configured for this app's API.
class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient.create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
      ),
    );
    return ApiClient._(dio);
  }
}

/// List endpoints return either a bare list (old API) or a paginated
/// `{items, total, limit, offset}` object (current API).
List<dynamic> unwrapList(dynamic data) =>
    data is Map<String, dynamic> ? data['items'] as List<dynamic> : data as List<dynamic>;
