import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer.dart';

/// Premium Customer Card — with press animation, avatar glow, and VIP treatment
class CustomerCard extends StatefulWidget {
  final Customer customer;
  final int orderCount;
  final DateTime? lastOrderDate;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.orderCount = 0,
    this.lastOrderDate,
    this.onTap,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
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

  bool get isVip => widget.orderCount >= 5;

  // Generate a consistent color from the customer name
  Color get _avatarColor {
    final colors = [
      const Color(0xFF2563EB), // blue
      const Color(0xFF7C3AED), // purple
      const Color(0xFF059669), // green
      const Color(0xFFD97706), // amber
      const Color(0xFFDC2626), // red
      const Color(0xFF0891B2), // cyan
    ];
    return colors[widget.customer.name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;

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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isVip
                  ? kAccentGold.withOpacity(0.3)
                  : kPrimary.withOpacity(0.07),
              width: isVip ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isVip
                    ? kAccentGold.withOpacity(0.06)
                    : kPrimary.withOpacity(0.05),
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Premium avatar with color + glow
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          getInitials(widget.customer.name),
                          style: AppTextStyles.labelLg.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (isVip)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: kAccentGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: kSurface, width: 2),
                          ),
                          child: const Icon(Icons.star,
                              size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.customer.name,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVip) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    kAccentGold,
                                    kAccentGold.withOpacity(0.7)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppStrings.vip,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 12, color: kTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            widget.customer.phone,
                            style: AppTextStyles.bodySm.copyWith(
                              color: kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (widget.lastOrderDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.history_outlined,
                                size: 12, color: kTextSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${AppStrings.lastOrder}  ${formatDate(widget.lastOrderDate!)}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: kTextSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: kPrimaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.orderCount} orders',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: kPrimary,
                    size: 20,
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
