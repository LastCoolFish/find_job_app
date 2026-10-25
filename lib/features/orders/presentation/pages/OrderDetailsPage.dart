import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';
import 'package:find_job_app/core/widgets/OpenOnSiteBar.dart';
import 'package:find_job_app/core/widgets/SectionCard.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/presentation/EngagementTracking.dart';
import 'package:find_job_app/features/analytics/presentation/widgets/EngagementSection.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';

/// Full order: customer, price, date, full description and statistics.
/// Opened with Navigator.push from the orders list, so going back returns
/// to the same list without reloading it.
class OrderDetailsPage extends StatefulWidget {
  final OrderEntity order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> with EngagementTracking {
  @override
  EventTarget get target => OrderTarget(widget.order.id);

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final textTheme = Theme.of(context).textTheme;
    final description = order.description.trim();

    return Scaffold(
      appBar: const FindJobAppBar(title: 'Заказ', icon: Symbols.assignment),
      bottomNavigationBar: OpenOnSiteBar(onPressed: () => openOnSite(order.siteHref)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: order.customer.name, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customer.name,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(order.platform, style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  order.name,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (order.price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(order.price!),
                    style: TextStyle(
                      color: AppColors.salary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Tag(
                  label: formatDateTime(order.publicationTimestamp),
                  icon: Symbols.schedule,
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Описание',
            child: Text(
              description.isEmpty ? 'Описание не указано' : description,
              style: textTheme.bodyLarge?.copyWith(
                color: description.isEmpty ? AppColors.muted : AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
          EngagementSection(engagement: engagement),
        ],
      ),
    );
  }
}
