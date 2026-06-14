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
  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final customer = widget.customer;
    final overdue = isOverdue(order.deliveryDate) && order.status != 'delivered';
    final dueToday = isDueToday(order.deliveryDate) && order.status != 'delivered';
    
    // Status drives the left accent color strip
    final statusColor = overdue ? kError : (order.isUrgent ? kAccentGold : getStatusColor(order.status));

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
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: kBorder.withOpacity(0.2), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LEFT COLUMN: ACCENT STATUS STRIP ---
                  Container(
                    width: 5,
                    color: statusColor,
                  ),

                  // --- MAIN DETAILS ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Order Number & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.orderNumber}',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: kTextSecondary.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              StatusChip(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Customer Name
                          Text(
                            customer?.name ?? AppStrings.unknownCustomer,
                            style: AppTextStyles.headlineSm.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Garment Type & Fabric Notes
                          Text(
                            order.garmentType +
                                (order.fabricNotes != null && order.fabricNotes!.isNotEmpty
                                    ? ' • ${order.fabricNotes}'
                                    : ''),
                            style: AppTextStyles.bodyMd.copyWith(
                              color: kTextSecondary.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 0.5, color: kBorder),
                          const SizedBox(height: 12),

                          // Bottom Row: Date/Urgency Indicator & Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Delivery Date
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: overdue ? kError : (dueToday ? Colors.orange : kTextSecondary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    overdue
                                        ? 'Overdue - ${order.deliveryDate.day} ${_getMonth(order.deliveryDate.month)}'
                                        : (dueToday
                                            ? 'Due Today'
                                            : 'Due: ${order.deliveryDate.day} ${_getMonth(order.deliveryDate.month)}'),
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: overdue ? kError : (dueToday ? Colors.orange : kTextSecondary),
                                      fontSize: 12,
                                      fontWeight: (overdue || dueToday) ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),

                              // Total Amount
                              Text(
                                formatCurrency(order.totalAmount),
                                style: AppTextStyles.headlineSm.copyWith(
                                  color: kPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
