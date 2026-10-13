import 'package:find_job_app/features/orders/domain/entities/CustomerEntity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.href,
    required super.platform,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      href: json['href'] as String?,
      platform: json['platform'] as String,
    );
  }
}
