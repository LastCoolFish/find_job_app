class AuthTokens {
  const AuthTokens(this.accessToken, this.refreshToken);
  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    json['access_token'] as String,
    json['refresh_token'] as String,
  );
}

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<String?> accessToken();
  Future<String?> refresh({String? rejectedToken});
  Future<void> clear();
  Future<void> logout();
}
