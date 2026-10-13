import 'package:equatable/equatable.dart';

/// Matches `CompanyBriefSchema` — a partial view of the company embedded
/// inside a vacancy response (no separate `/companies` endpoint exists).
class CompanyEntity extends Equatable {
  final int id;
  final String name;
  final int? rating;
  final bool accreditation;

  const CompanyEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.accreditation,
  });

  @override
  List<Object?> get props => [id, name, rating, accreditation];
}
