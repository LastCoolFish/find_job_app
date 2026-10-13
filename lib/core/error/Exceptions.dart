/// Thrown by the data layer (datasources) when a request fails.
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server error']);
}

/// Thrown by the data layer when the device has no network connection.
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);
}
