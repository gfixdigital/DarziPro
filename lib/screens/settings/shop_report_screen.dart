import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/hive_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/strings.dart';

class ShopReportScreen extends StatelessWidget {
  const ShopReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = HiveService.customersBoxInstance.values.where((c) => !c.isDeleted).toList();
    final orders = HiveService.ordersBoxInstance.values.where((o) => !o.isDeleted).toList();
    
    final totalRevenue = orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
    final totalReceived = orders.fold<double>(0, (sum, o) => sum + o.advancePaid);
    final pendingBalance = orders.fold<double>(0, (sum, o) => sum + o.remainingBalance);
    
    final completedOrders = orders.where((o) => o.status == 'delivered').length;
    final pendingOrders = orders.where((o) => o.status == 'pending' || o.status == 'processing').length;
    final readyOrders = orders.where((o) => o.status == 'ready').length;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(AppStrings.shopPerformanceReport),
        backgroundColor: kBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.financialOverview, style: AppTextStyles.headlineSm),
            const SizedBox(height: 12),
            _buildStatCard('Total Revenue', formatCurrency(totalRevenue), Icons.payments_outlined, kPrimary),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Received', formatCurrency(totalReceived), Icons.download_done, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending Due', formatCurrency(pendingBalance), Icons.pending_actions, kError)),
              ],
            ),
            const SizedBox(height: 24),
            Text(AppStrings.orderStatistics, style: AppTextStyles.headlineSm),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Orders', '${orders.length}', Icons.receipt_long, kPrimary)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Completed', '$completedOrders', Icons.check_circle_outline, Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('In Progress', '$pendingOrders', Icons.sync, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Ready for Pickup', '$readyOrders', Icons.shopping_bag_outlined, kAccentGold)),
              ],
            ),
            const SizedBox(height: 24),
            Text(AppStrings.customerBase, style: AppTextStyles.headlineSm),
            const SizedBox(height: 12),
            _buildStatCard('Total Customers', '${customers.length}', Icons.people_outline, kPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineSm.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
