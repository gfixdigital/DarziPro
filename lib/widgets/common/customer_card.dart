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
          margin: const EdgeInsets.only(bottom: 28, top: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Card Body
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isVip
                        ? kAccentGold.withOpacity(0.4)
                        : kBorder.withOpacity(0.5),
                    width: isVip ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isVip
                          ? kAccentGold.withOpacity(0.1)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.customer.name,
                            style: AppTextStyles.headlineSm.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVip)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  kAccentGold,
                                  kAccentGold.withOpacity(0.8)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.vip,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                           Icon(Icons.chevron_right_rounded, color: kTextSecondary.withOpacity(0.3), size: 24),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Phone Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: 16, color: color),
                              const SizedBox(width: 8),
                              Text(
                                widget.customer.phone,
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: kTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (widget.lastOrderDate != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppStrings.lastOrder,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: kTextSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDate(widget.lastOrderDate!),
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: kTextPrimary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Avatar
              Positioned(
                top: -24,
                left: 24,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    border: Border.all(color: kSurface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      getInitials(widget.customer.name),
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Orders Pill
              Positioned(
                top: -12,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kPrimaryDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kSurface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryDark.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    '${widget.orderCount} Orders',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
