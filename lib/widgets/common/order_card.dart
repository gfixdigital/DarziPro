import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import 'status_chip.dart';

/// Premium Order Card — elevated glassmorphism style with rich micro-details
class OrderCard extends StatefulWidget {
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
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final customer = widget.customer;
    final overdue = isOverdue(order.deliveryDate) && order.status != 'delivered';
    final dueToday = isDueToday(order.deliveryDate) && order.status != 'delivered';
    final statusColor = getStatusColor(order.status);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: IntrinsicHeight(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: order.isUrgent
                    ? kAccentGold.withOpacity(0.35)
                    : kPrimary.withOpacity(0.07),
                width: order.isUrgent ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.06),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle status tint in top-right corner
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar — urgent=gold, normal=status color
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: order.isUrgent
                              ? [kAccentGold, kAccentGold.withOpacity(0.6)]
                              : [statusColor, statusColor.withOpacity(0.4)],
                        ),
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: order # + status chip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${order.orderNumber}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: kPrimary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (order.isUrgent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: kAccentGold.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.bolt,
                                                size: 10, color: kAccentGold),
                                            const SizedBox(width: 2),
                                            Text(
                                              'URGENT',
                                              style:
                                                  AppTextStyles.labelSm.copyWith(
                                                color: kAccentGold,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 9,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                StatusChip(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Customer name
                            Text(
                              customer?.name ?? AppStrings.unknownCustomer,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Garment type
                            Text(
                              order.garmentType +
                                  (order.fabricNotes != null &&
                                          order.fabricNotes!.isNotEmpty
                                      ? ' · ${order.fabricNotes}'
                                      : ''),
                              style: AppTextStyles.bodySm.copyWith(
                                color: kTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),

                            // Divider
                            Container(
                              height: 1,
                              color: kSurfaceContainerHigh.withOpacity(0.5),
                            ),
                            const SizedBox(height: 10),

                            // Bottom row: delivery + amount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: overdue
                                              ? kError.withOpacity(0.1)
                                              : dueToday
                                                  ? Colors.orange
                                                      .withOpacity(0.1)
                                                  : kSurfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 12,
                                          color: overdue
                                              ? kError
                                              : dueToday
                                                  ? Colors.orange
                                                  : kTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          overdue
                                              ? '${AppStrings.overdue} (${formatDate(order.deliveryDate)})'
                                              : dueToday
                                                  ? AppStrings.dueToday
                                                  : formatDate(
                                                      order.deliveryDate),
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: overdue
                                                ? kError
                                                : dueToday
                                                    ? Colors.orange
                                                    : kTextSecondary,
                                            fontWeight: overdue || dueToday
                                                ? FontWeight.w700
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formatCurrency(order.totalAmount),
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (order.status == 'ready') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: kPrimary.withOpacity(0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_active_outlined,
                                        size: 12, color: kPrimary),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.awaitingCustomer,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: kPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
