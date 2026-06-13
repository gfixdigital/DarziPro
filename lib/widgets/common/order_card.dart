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
    
    // Status drives the ticket stub color
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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: kBorder.withOpacity(0.3), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LEFT COLUMN: TICKET STUB (Bold Date & Order Number) ---
                  Container(
                    width: 85,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: statusColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${order.deliveryDate.day}',
                          style: AppTextStyles.headlineLg.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getMonth(order.deliveryDate.month),
                          style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${order.orderNumber}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- RIGHT COLUMN: MAIN DETAILS ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  customer?.name ?? AppStrings.unknownCustomer,
                                  style: AppTextStyles.headlineSm.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                    color: kTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              StatusChip(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.garmentType +
                                (order.fabricNotes != null && order.fabricNotes!.isNotEmpty
                                    ? ' • ${order.fabricNotes}'
                                    : ''),
                            style: AppTextStyles.bodyMd.copyWith(
                              color: kTextSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL AMOUNT',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: kTextSecondary.withOpacity(0.7),
                                      letterSpacing: 1.2,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatCurrency(order.totalAmount),
                                    style: AppTextStyles.headlineMd.copyWith(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              if (order.status == 'ready' || overdue || dueToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: overdue
                                        ? kError.withOpacity(0.1)
                                        : (dueToday ? Colors.orange.withOpacity(0.1) : kPrimary.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        overdue
                                            ? Icons.warning_amber_rounded
                                            : (dueToday ? Icons.schedule : Icons.check_circle_outline),
                                        size: 14,
                                        color: overdue ? kError : (dueToday ? Colors.orange : kPrimary),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        overdue ? 'OVERDUE' : (dueToday ? 'DUE TODAY' : 'READY'),
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: overdue ? kError : (dueToday ? Colors.orange : kPrimary),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
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
