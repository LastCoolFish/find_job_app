import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.role,
    required super.createdAt,
    required super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final lastLogin = json['last_login_at'] as String?;
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: lastLogin == null ? null : DateTime.parse(lastLogin),
    );
  }
}
