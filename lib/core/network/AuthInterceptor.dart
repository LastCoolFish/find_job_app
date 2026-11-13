import 'package:dio/dio.dart';
import 'package:find_job_app/features/auth/domain/repositories/AuthRepository.dart';

/// Opt in per protected request with Options(extra: {'requiresAuth': true}).
/// The callback is connected to navigation when the auth screens are integrated.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this.repository,
    this.retryClient, {
    required this.onLoginRequired,
  });
  final AuthRepository repository;
  final Dio retryClient;
  final void Function() onLoginRequired;

  DioException _error(RequestOptions options, Object error) =>
      DioException(requestOptions: options, error: error);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['requiresAuth'] != true) return handler.next(options);
    try {
      final token = await repository.accessToken();
      if (token == null) {
        onLoginRequired();
        return handler.reject(_error(options, 'Authentication required'));
      }
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (error) {
      handler.reject(_error(options, error));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final error = err;
    final options = error.requestOptions;
    if (options.extra['requiresAuth'] != true ||
        options.extra['authRetried'] == true ||
        error.response?.statusCode != 401)
      return handler.next(error);
    try {
      final auth = options.headers['Authorization'] as String?;
      final token = await repository.refresh(
        rejectedToken: auth?.replaceFirst('Bearer ', ''),
      );
      if (token == null) {
        onLoginRequired();
        return handler.next(error);
      }
      options.headers['Authorization'] = 'Bearer $token';
      options.extra['authRetried'] = true;
      final response = await retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await repository.clear();
        onLoginRequired();
      }
      handler.next(retryError);
    } catch (failure) {
      handler.next(_error(options, failure));
    }
  }
}
