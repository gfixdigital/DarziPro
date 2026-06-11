import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer.dart';

/// Customer card widget — avatar with initials, name, phone, last order date
/// Gold left border for VIP customers (5+ orders)
class CustomerCard extends StatelessWidget {
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

  bool get isVip => orderCount >= 5;

  @override
  Widget build(BuildContext context) {
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
            // Gold accent bar for VIP
            if (isVip)
              Container(
                width: 4,
                height: 72,
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
                  left: isVip ? 12 : 16,
                  right: 16,
                  top: 14,
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    // Avatar with initials
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          getInitials(customer.name),
                          style: AppTextStyles.labelLg.copyWith(
                            color: kPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customer info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  customer.name,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isVip)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kAccentGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    AppStrings.vip,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: kAccentGold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customer.phone,
                            style: AppTextStyles.bodySm,
                          ),
                          if (lastOrderDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${AppStrings.lastOrder}  ${formatDate(lastOrderDate!)}',
                              style: AppTextStyles.labelSm.copyWith(
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: kTextSecondary,
                    ),
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
