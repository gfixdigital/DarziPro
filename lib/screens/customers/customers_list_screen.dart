import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/customer_card.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProv = context.watch<CustomerProvider>();
    final orderProv = context.read<OrderProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(AppStrings.customers, style: AppTextStyles.headlineMd),
          const SizedBox(height: 4),
          Text(AppStrings.customersSubtitle, style: AppTextStyles.bodySm),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            onChanged: (v) => customerProv.setSearchQuery(v),
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              hintStyle: AppTextStyles.bodyMd.copyWith(color: kTextSecondary.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: kTextSecondary),
              filled: true,
              fillColor: kPrimaryLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Customer list
          Expanded(
            child: customerProv.customers.isEmpty
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
                            Icons.people_outline,
                            color: kPrimary.withOpacity(0.6),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.noCustomersYet,
                          style: AppTextStyles.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.addFirstCustomer,
                          style: AppTextStyles.bodySm.copyWith(color: kTextSecondary),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: kPrimary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      context.read<CustomerProvider>().loadCustomers();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: customerProv.customers.length,
                      itemBuilder: (context, index) {
                        final customer = customerProv.customers[index];
                        final orders = orderProv.getOrdersForCustomer(customer.id);
                        final lastOrder = orders.isNotEmpty ? orders.first.orderDate : null;
                        return CustomerCard(
                          customer: customer,
                          orderCount: orders.length,
                          lastOrderDate: lastOrder,
                          onTap: () => Navigator.pushNamed(
                            context, '/customers/${customer.id}',
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
