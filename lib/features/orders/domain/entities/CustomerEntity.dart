import 'package:equatable/equatable.dart';

/// Matches `CustomerBriefSchema` — a partial view of the customer embedded
/// inside an order response (no separate `/customers` endpoint exists).
class CustomerEntity extends Equatable {
  final int id;
  final String name;
  final String? href;
  final String platform;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.href,
    required this.platform,
  });

  @override
  List<Object?> get props => [id, name, href, platform];
}
