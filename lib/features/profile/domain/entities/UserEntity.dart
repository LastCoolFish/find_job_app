import 'package:equatable/equatable.dart';

/// Matches `UserOutSchema`: the account behind a profile.
class UserEntity extends Equatable {
  final int id;
  final String email;
  final String? phone;
  final String role; // "user", "admin" or "blocked"
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, phone, role, createdAt, lastLoginAt];
}
