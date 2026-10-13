import 'package:equatable/equatable.dart';
import 'package:find_job_app/features/orders/domain/entities/CustomerEntity.dart';

/// Matches `OrderOutSchema` from the FastAPI backend.
class OrderEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final int? price;
  final DateTime publicationTimestamp;
  final String platform;
  final int platformId;
  final String siteHref;
  final CustomerEntity customer;

  const OrderEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.publicationTimestamp,
    required this.platform,
    required this.platformId,
    required this.siteHref,
    required this.customer,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        publicationTimestamp,
        platform,
        platformId,
        siteHref,
        customer,
      ];
}
