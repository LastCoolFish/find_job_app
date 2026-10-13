import 'package:find_job_app/features/orders/data/models/CustomerModel.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.publicationTimestamp,
    required super.platform,
    required super.platformId,
    required super.siteHref,
    required super.customer,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int?,
      publicationTimestamp: DateTime.parse(json['publication_timestamp'] as String),
      platform: json['platform'] as String,
      platformId: json['platform_id'] as int,
      siteHref: json['site_href'] as String,
      customer: CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }
}
