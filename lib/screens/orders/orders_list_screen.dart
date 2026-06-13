import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/order_card.dart';

/// Orders List Screen — matches Stitch "Orders List" design
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final List<Map<String, String>> _filters = [
    {'key': 'all', 'label': AppStrings.allActive},
    {'key': 'pending', 'label': AppStrings.pending},
    {'key': 'cutting', 'label': AppStrings.cutting},
    {'key': 'in_progress', 'label': AppStrings.inProgress},
    {'key': 'ready', 'label': AppStrings.ready},
    {'key': 'delivered', 'label': AppStrings.delivered},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header
          Text(AppStrings.orders, style: AppTextStyles.headlineMd),
          const SizedBox(height: 4),
          Text(AppStrings.ordersSubtitle, style: AppTextStyles.bodySm),
          const SizedBox(height: 16),

          // Filter chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isActive = orderProvider.filterStatus == filter['key'];
                return GestureDetector(
                  onTap: () => orderProvider.setFilter(filter['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? kPrimary : kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? kPrimary
                            : kBorder.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      filter['label']!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isActive ? Colors.white : kTextSecondary,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Orders list
          Expanded(
            child: orderProvider.orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: kPrimary.withOpacity(0.1), width: 2),
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            color: kPrimary.withOpacity(0.6),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No orders found',
                          style: AppTextStyles.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a new order to get started',
                          style: AppTextStyles.bodySm.copyWith(color: kTextSecondary),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: kPrimary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      context.read<OrderProvider>().loadOrders();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: orderProvider.orders.length,
                      itemBuilder: (context, index) {
                        final order = orderProvider.orders[index];
                        final customer = context
                            .read<CustomerProvider>()
                            .getCustomerById(order.customerId);
                        return OrderCard(
                          order: order,
                          customer: customer,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/orders/${order.id}',
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
