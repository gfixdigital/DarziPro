import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import 'status_chip.dart';

/// Order card widget — matching Stitch design
/// Shows order number, customer, garment type, delivery date, status
/// Gold left border if urgent
class OrderCard extends StatelessWidget {
  final Order order;
  final Customer? customer;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.customer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = isOverdue(order.deliveryDate) && order.status != 'delivered';
    final dueToday = isDueToday(order.deliveryDate) && order.status != 'delivered';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kPrimary.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gold accent bar for urgent orders
            if (order.isUrgent)
              Container(
                width: 4,
                height: 100,
                decoration: BoxDecoration(
                  color: kAccentGold,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: order.isUrgent ? 12 : 16,
                  right: 16,
                  top: 14,
                  bottom: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: order number + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${order.orderNumber}',
                          style: AppTextStyles.labelLg.copyWith(
                            color: kPrimary,
                          ),
                        ),
                        StatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Customer name
                    Text(
                      customer?.name ?? AppStrings.unknownCustomer,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Garment type + fabric notes
                    Text(
                      order.garmentType +
                          (order.fabricNotes != null && order.fabricNotes!.isNotEmpty
                              ? ' — ${order.fabricNotes}'
                              : ''),
                      style: AppTextStyles.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Bottom row: delivery date + amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delivery date
                        Flexible(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: overdue ? kError : kTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  overdue
                                      ? '${AppStrings.overdue} (${formatDate(order.deliveryDate)})'
                                      : dueToday
                                          ? AppStrings.dueToday
                                          : '${AppStrings.due}: ${formatDate(order.deliveryDate)}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: overdue
                                        ? kError
                                        : dueToday
                                            ? Colors.orange
                                            : kTextSecondary,
                                    fontWeight: overdue || dueToday
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Amount
                        Text(
                          formatCurrency(order.totalAmount),
                          style: AppTextStyles.labelLg,
                        ),
                      ],
                    ),

                    // "Awaiting Customer" label
                    if (order.status == 'ready') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppStrings.awaitingCustomer,
                          style: AppTextStyles.labelSm.copyWith(
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
