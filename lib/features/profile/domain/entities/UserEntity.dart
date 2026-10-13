import 'package:equatable/equatable.dart';

enum UserRole { user, admin, blocked }

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.user,
  );
}

/// Matches `UserOutSchema` from the FastAPI backend.
class UserEntity extends Equatable {
  final int id;
  final String email;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, phone, role, createdAt, updatedAt, lastLoginAt];
}
