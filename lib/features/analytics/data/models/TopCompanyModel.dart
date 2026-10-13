import 'package:find_job_app/features/analytics/domain/entities/TopCompanyEntity.dart';
import 'package:find_job_app/features/vacancies/data/models/CompanyModel.dart';

class TopCompanyModel extends TopCompanyEntity {
  const TopCompanyModel({required super.company, required super.vacancyCount});

  factory TopCompanyModel.fromJson(Map<String, dynamic> json) {
    return TopCompanyModel(
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      vacancyCount: json['vacancy_count'] as int,
    );
  }
}
