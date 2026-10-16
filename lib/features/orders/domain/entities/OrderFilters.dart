import 'package:equatable/equatable.dart';

/// How to sort orders. The API sorts by `sort_by` + `order`.
enum OrderSort {
  newest('Сначала новые', 'publication_timestamp', 'desc'),
  oldest('Сначала старые', 'publication_timestamp', 'asc'),
  priceHigh('Сначала дорогие', 'price', 'desc'),
  priceLow('Сначала дешёвые', 'price', 'asc');

  final String label;
  final String sortBy;
  final String order;

  const OrderSort(this.label, this.sortBy, this.order);
}

/// Search filters for `GET /orders/search`. Null means "don't filter".
class OrderFilters extends Equatable {
  // Substring, case-insensitive. The server currently finds nothing for
  // Cyrillic text (Latin like "Python" works).
  final String? name;
  final int? priceMin;
  final int? priceMax;
  final String? platform; // e.g. 'kwork' or 'fl', see /orders/platforms
  final OrderSort sort;

  const OrderFilters({
    this.name,
    this.priceMin,
    this.priceMax,
    this.platform,
    this.sort = OrderSort.newest,
  });

  /// How many filters are set (sorting is not counted), for the badge
  /// on the filters button.
  int get activeCount =>
      [name, priceMin, priceMax, platform].where((value) => value != null).length;

  Map<String, dynamic> toQueryParameters() {
    // "price desc" puts orders without a price first, so when sorting by
    // price only show orders that have one.
    final isPriceSort = sort == OrderSort.priceHigh || sort == OrderSort.priceLow;
    final effectivePriceMin = priceMin ?? (isPriceSort ? 1 : null);

    return {
      'name': ?name,
      'price_min': ?effectivePriceMin,
      'price_max': ?priceMax,
      'platform': ?platform,
      'sort_by': sort.sortBy,
      'order': sort.order,
    };
  }

  @override
  List<Object?> get props => [name, priceMin, priceMax, platform, sort];
}
