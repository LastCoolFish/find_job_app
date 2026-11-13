import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/ListingCard.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onTap, this.onDetails});

  final OrderEntity order;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final description = order.description.trim();
    final price = order.price;
    final textTheme = Theme.of(context).textTheme;
    return ListingCard(
      author: order.customer.name,
      source: order.platform.toLowerCase() == 'kwork'
          ? 'Kwork'
          : order.platform,
      title: order.name,
      onTap: onTap,
      onDetails: onDetails,
      children: [
        if (description.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (price != null)
              Text(
                formatMoney(price),
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.salary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.muted),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    formatDateTime(order.publicationTimestamp),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
