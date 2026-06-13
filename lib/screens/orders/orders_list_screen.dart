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

    return Scaffold(
      backgroundColor: kBackground,
      body: RefreshIndicator(
        color: kPrimary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          context.read<OrderProvider>().loadOrders();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Dynamic Collapsing Header
            SliverAppBar(
              backgroundColor: kBackground,
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  AppStrings.orders,
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: kTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Container(
                  color: kBackground,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppStrings.ordersSubtitle,
                    style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary),
                  ),
                ),
              ),
            ),

            // Sticky Pinned Filters
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                child: Container(
                  color: kBackground.withOpacity(0.95),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isActive = orderProvider.filterStatus == filter['key'];
                        return GestureDetector(
                          onTap: () => orderProvider.setFilter(filter['key']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? kPrimaryDark : kSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? kPrimaryDark
                                    : kBorder.withOpacity(0.4),
                                width: isActive ? 0 : 1,
                              ),
                              boxShadow: isActive ? [
                                BoxShadow(
                                  color: kPrimaryDark.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                filter['label']!,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isActive ? Colors.white : kTextSecondary,
                                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable List Body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: orderProvider.orders.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
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
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: orderProvider.orders.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 66.0;

  @override
  double get minExtent => 66.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
