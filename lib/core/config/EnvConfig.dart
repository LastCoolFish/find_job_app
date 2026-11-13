class EnvConfig {
  EnvConfig._();

  static String baseUrl = "http://localhost:8000";

  /// There is no login yet, so the profile tab shows this user.
  static int currentUserId = 0;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
