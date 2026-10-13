import 'package:find_job_app/features/vacancies/domain/entities/CompanyEntity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.name,
    required super.rating,
    required super.accreditation,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      rating: json['rating'] as int?,
      accreditation: json['accreditation'] as bool,
    );
  }
}
