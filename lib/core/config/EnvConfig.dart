class EnvConfig {
  EnvConfig._();

  static String baseUrl = "http://46.29.114.103:8000";

  /// There is no login yet, so the profile tab shows this user.
  static const int currentUserId = 1;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
