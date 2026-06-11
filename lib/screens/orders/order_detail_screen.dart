import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/common/sync_indicator.dart';

/// Order Detail Screen — matches Stitch "Order Details" design
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  Customer? _customer;
  Measurement? _measurement;
  Measurement? _customerMeasurement; // fallback from customer profile
  StylePreference? _style;
  bool _measurementIsFromCustomer = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final orderProvider = context.read<OrderProvider>();
    _order = orderProvider.getOrderById(widget.orderId);
    if (_order != null) {
      _customer = context.read<CustomerProvider>().getCustomerById(_order!.customerId);
      _measurement = orderProvider.getMeasurementForOrder(_order!.id);
      _style = orderProvider.getStyleForOrder(_order!.id);
      // If no order-specific measurements, fall back to customer default measurements
      if (_measurement == null && _customer != null) {
        _customerMeasurement = context
            .read<CustomerProvider>()
            .getCustomerMeasurements(_customer!.id);
        _measurementIsFromCustomer = _customerMeasurement != null;
      } else {
        _measurementIsFromCustomer = false;
      }
    }
  }

  Future<void> _openWhatsApp() async {
    if (_customer == null || _order == null) return;
    final cleaned = cleanPhoneForWhatsApp(_customer!.phone);
    final message = Uri.encodeComponent(
      AppStrings.whatsAppMessage(_customer!.name, _order!.orderNumber),
    );
    final url = 'whatsapp://send?phone=$cleaned&text=$message';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.whatsappNotInstalled),
              backgroundColor: kError,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kError),
        );
      }
    }
  }

  void _updateStatus(String newStatus) {
    context.read<OrderProvider>().updateOrderStatus(widget.orderId, newStatus);
    setState(() => _loadData());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${getStatusLabel(newStatus)}'),
        backgroundColor: kPrimary,
      ),
    );
  }

  String _getNextStatus() {
    switch (_order?.status) {
      case 'pending':
        return 'cutting';
      case 'cutting':
        return 'in_progress';
      case 'in_progress':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return 'pending';
    }
  }

  String _getNextStatusLabel() {
    switch (_order?.status) {
      case 'pending':
        return AppStrings.startCutting;
      case 'cutting':
        return AppStrings.markInProgress;
      case 'in_progress':
        return AppStrings.markAsReady;
      case 'ready':
        return AppStrings.markAsDelivered;
      default:
        return AppStrings.updateStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(title: Text(AppStrings.orderNotFound)),
        body: Center(child: Text(AppStrings.orderNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          const SyncIndicator(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  backgroundColor: kBackground,
                  foregroundColor: kTextPrimary,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'Order #${_order!.orderNumber}',
                    style: AppTextStyles.headlineSm,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: StatusChip(status: _order!.status),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer card
                        _buildCustomerCard(),
                        const SizedBox(height: 16),

                        // Style preferences
                        if (_style != null) ...[
                          _buildStyleSection(),
                          const SizedBox(height: 16),
                        ],

                        // Measurements (order-specific or customer fallback)
                        if (_measurement != null || _customerMeasurement != null) ...[
                          _buildMeasurementsSection(_measurement ?? _customerMeasurement!),
                          const SizedBox(height: 16),
                        ],

                        // Payment card
                        _buildPaymentCard(),
                        const SizedBox(height: 24),

                        // Action buttons
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kSurface,
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary.withOpacity(0.15)),
            ),
            child: Center(
              child: Text(
                getInitials(_customer?.name ?? '?'),
                style: AppTextStyles.labelLg.copyWith(
                  color: kPrimary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customer?.name ?? 'Unknown',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _customer?.phone ?? '',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          // WhatsApp button
          IconButton(
            onPressed: _openWhatsApp,
            icon: const Icon(Icons.chat, color: kPrimary),
            tooltip: 'Send WhatsApp',
            style: IconButton.styleFrom(
              backgroundColor: kSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSection() {
    final styleMap = _style!.displayMap;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.step3Title, style: AppTextStyles.labelLg),
              Text(_order!.garmentType, style: AppTextStyles.bodySm),
            ],
          ),
          if (_order!.fabricNotes != null && _order!.fabricNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Fabric: ${_order!.fabricNotes}',
              style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const Divider(height: 20),
          ...styleMap.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: AppTextStyles.bodySm),
                    Text(
                      e.value,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection(Measurement m) {
    final measurements = m.displayMap;
    final entries = measurements.entries.where((e) => e.value != null).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.measurementsInches, style: AppTextStyles.labelLg),
                  if (_measurementIsFromCustomer)
                    Text(
                      AppStrings.fromCustomerProfile,
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              if (_customer != null)
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/customers/${_customer!.id}',
                  ),
                  child: Text(
                    AppStrings.edit,
                    style: AppTextStyles.labelLg.copyWith(color: kPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                AppStrings.noMeasurementsRecorded,
                style: AppTextStyles.bodySm.copyWith(color: kTextSecondary),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 8,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: index % 3 == 0
                        ? kPrimaryLight.withOpacity(0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: AppTextStyles.labelSm),
                      Text(
                        '${entry.value}"',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (m.fitNotes != null && m.fitNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.fitNotes, style: AppTextStyles.labelSm),
                  const SizedBox(height: 4),
                  Text(m.fitNotes!, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.paymentStatus,
            style: AppTextStyles.labelLg.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(_order!.totalAmount),
            style: AppTextStyles.currencyLg.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Amount',
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      formatCurrency(_order!.advancePaid),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.depositPaid,
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      formatCurrency(_order!.remainingBalance),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: _order!.balancePaid
                            ? Colors.white
                            : const Color(0xFFFFDAD6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.balanceDue,
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: AppStrings.invoice,
                isOutlined: true,
                icon: Icons.receipt_long_outlined,
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/orders/${widget.orderId}/invoice',
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (_order!.status != 'delivered')
              Expanded(
                child: AppButton(
                  text: _getNextStatusLabel(),
                  onPressed: () => _updateStatus(_getNextStatus()),
                ),
              ),
          ],
        ),
        if (!_order!.balancePaid && _order!.remainingBalance > 0) ...[
          const SizedBox(height: 12),
          AppButton(
            text: AppStrings.collectPayment,
            icon: Icons.payments_outlined,
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/orders/${widget.orderId}/payment',
              );
              setState(() => _loadData());
            },
          ),
        ],
      ],
    );
  }
}
