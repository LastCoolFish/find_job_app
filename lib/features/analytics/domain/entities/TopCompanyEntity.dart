import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/vacancies/domain/entities/CompanyEntity.dart';

/// Matches `CompanyVacancyCountSchema` (from `/analytics/top-companies`) — a
/// computed ranking, not a mirror of a stored table.
class TopCompanyEntity extends Equatable {
  final CompanyEntity company;
  final int vacancyCount;

  const TopCompanyEntity({required this.company, required this.vacancyCount});

  @override
  List<Object?> get props => [company, vacancyCount];
}
