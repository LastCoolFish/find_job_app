import 'package:equatable/equatable.dart';

/// Matches `ProfileOutSchema` from the FastAPI backend.
class ProfileEntity extends Equatable {
  final int id;
  final int userId;
  final String? name;
  final String username;
  final int? desiredSalary;
  final String? desiredFormat;
  final int? desiredGrade;

  const ProfileEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    required this.desiredSalary,
    required this.desiredFormat,
    required this.desiredGrade,
  });

  @override
  List<Object?> get props =>
      [id, userId, name, username, desiredSalary, desiredFormat, desiredGrade];
}
