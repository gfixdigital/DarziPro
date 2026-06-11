import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/common/app_button.dart';

class CollectPaymentScreen extends StatefulWidget {
  final String orderId;
  const CollectPaymentScreen({super.key, required this.orderId});

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderProvider>().getOrderById(widget.orderId);
    if (order != null) {
      _amountController.text = order.remainingBalance.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.enterValidAmount), backgroundColor: kError),
      );
      return;
    }
    context.read<OrderProvider>().collectPayment(widget.orderId, amount);
    // Trigger sync so payment goes to Supabase immediately
    context.read<SyncProvider>().syncNow();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ${formatCurrency(amount)} collected! ✓'),
        backgroundColor: kPrimary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().getOrderById(widget.orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.error)),
        body: Center(child: Text(AppStrings.orderNotFound)),
      );
    }
    final customer = context.read<CustomerProvider>().getCustomerById(order.customerId);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        foregroundColor: kTextPrimary,
        elevation: 0,
        title: Text(AppStrings.collectPayment, style: AppTextStyles.headlineSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer + Order card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimary.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer?.name ?? 'Customer',
                      style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                  Text('Order #${order.orderNumber}', style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(AppStrings.totalAmount, style: AppTextStyles.labelSm),
                  const SizedBox(height: 4),
                  Text(formatCurrency(order.totalAmount),
                      style: AppTextStyles.currencyLg),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Advance + Remaining
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(AppStrings.advancePaid, style: AppTextStyles.labelSm),
                        const SizedBox(height: 4),
                        Text(formatCurrency(order.advancePaid),
                            style: AppTextStyles.currencyMd.copyWith(color: kTextSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(AppStrings.remainingBalance, style: AppTextStyles.labelSm),
                        const SizedBox(height: 4),
                        Text(formatCurrency(order.remainingBalance),
                            style: AppTextStyles.currencyMd.copyWith(color: kError)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount input
            Text(AppStrings.enterAmountReceived, style: AppTextStyles.labelLg),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: AppTextStyles.currencyMd,
              decoration: InputDecoration(
                prefixText: 'Rs. ',
                prefixStyle: AppTextStyles.currencyMd.copyWith(color: kTextSecondary),
                filled: true,
                fillColor: kPrimaryLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kBorder.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(AppStrings.fullBalancePopulated,
                style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
            const SizedBox(height: 32),

            AppButton(
              text: AppStrings.markAsPaid,
              onPressed: _handlePayment,
            ),
          ],
        ),
      ),
    );
  }
}
