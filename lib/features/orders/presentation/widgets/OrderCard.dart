import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onDetails,
  });

  static const _maxDescriptionLines = 3;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(name: order.customer.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.platform,
                            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.name,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          order.description.trim(),
                          maxLines: _maxDescriptionLines,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                        ),
                      ],
                      if (order.price != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          formatMoney(order.price!),
                          // Same as the salary in VacancyCard.
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.salary,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Tag(
                        label: formatDateTime(order.publicationTimestamp),
                        icon: Symbols.schedule,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: onDetails,
                          style: FilledButton.styleFrom(
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Подробнее'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
