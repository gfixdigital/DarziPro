import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/hive_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import '../../widgets/common/app_button.dart';

class InvoiceScreen extends StatefulWidget {
  final String orderId;
  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Order? _order;
  Customer? _customer;
  Measurement? _measurement;
  StylePreference? _style;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final op = context.read<OrderProvider>();
    final cp = context.read<CustomerProvider>();
    _order = op.getOrderById(widget.orderId);
    if (_order != null) {
      _customer = cp.getCustomerById(_order!.customerId);
      _measurement = op.getMeasurementForOrder(_order!.id);
      _measurement ??= _customer != null
          ? cp.getCustomerMeasurements(_customer!.id)
          : null;
      _style = op.getStyleForOrder(_order!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.invoice)),
        body: Center(child: Text(AppStrings.orderNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        foregroundColor: kTextPrimary,
        elevation: 0,
        title: Text('Invoice #${_order!.orderNumber}', style: AppTextStyles.headlineSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceCard(),
            const SizedBox(height: 20),
            AppButton(
              text: 'Share via WhatsApp',
              icon: Icons.chat_outlined,
              onPressed: _shareWhatsApp,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        Text(
                          HiveService.shopName ?? 'Darzi Pro',
                          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                        ),
                        if ((HiveService.contactNumber ?? '').isNotEmpty)
                          Text(
                            _formatPhone(HiveService.contactNumber!),
                            style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'INVOICE',
                        style: AppTextStyles.labelLg.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _invoiceHeaderItem('Order #', _order!.orderNumber),
                    _invoiceHeaderItem('Date', formatDate(_order!.orderDate)),
                    _invoiceHeaderItem('Delivery', formatDate(_order!.deliveryDate)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Customer Info ────────────────────────
                _sectionHeader(Icons.person_outline, 'Customer'),
                const SizedBox(height: 10),
                _infoRow('Name', _customer?.name ?? 'Unknown'),
                _infoRow('Phone', _formatPhone(_customer?.phone ?? '—')),
                if ((_customer?.address ?? '').isNotEmpty)
                  _infoRow('Address', _customer!.address!),

                _divider(),

                // ── Garment Details ──────────────────────
                _sectionHeader(Icons.checkroom_outlined, 'Garment Details'),
                const SizedBox(height: 10),
                _infoRow('Type', _order!.garmentType),
                _infoRow('Status', getStatusLabel(_order!.status)),
                if (_order!.isUrgent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Text(
                        '⚡ Urgent Order',
                        style: AppTextStyles.labelSm.copyWith(color: Colors.orange.shade800),
                      ),
                    ),
                  ),
                if ((_order!.fabricNotes ?? '').isNotEmpty)
                  _infoRow('Fabric', _order!.fabricNotes!),
                if ((_order!.orderNotes ?? '').isNotEmpty)
                  _infoRow('Notes', _order!.orderNotes!),

                // ── Style Preferences ────────────────────
                if (_style != null) ...[
                  _divider(),
                  _sectionHeader(Icons.style_outlined, 'Style Preferences'),
                  const SizedBox(height: 10),
                  ..._style!.displayMap.entries.map((e) => _infoRow(e.key, e.value)),
                ],

                // ── Measurements ─────────────────────────
                if (_measurement != null) ...[
                  _divider(),
                  _sectionHeader(Icons.straighten_outlined, 'Measurements (inches)'),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _measurement!.displayMap.entries
                        .where((e) => e.value != null)
                        .length,
                    itemBuilder: (context, index) {
                      final entries = _measurement!.displayMap.entries
                          .where((e) => e.value != null)
                          .toList();
                      final e = entries[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: AppTextStyles.labelSm),
                            Text(
                              '${e.value}"',
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if ((_measurement!.fitNotes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _infoRow('Fit Notes', _measurement!.fitNotes!),
                  ],
                ],

                _divider(),

                // ── Payment Summary ──────────────────────
                _sectionHeader(Icons.payments_outlined, 'Payment Summary'),
                const SizedBox(height: 10),
                _paymentRow('Total Amount', formatCurrency(_order!.totalAmount), bold: true),
                _paymentRow('Deposit Paid', formatCurrency(_order!.advancePaid)),
                const Divider(height: 20, thickness: 0.5),
                _paymentRow(
                  'Balance Due',
                  formatCurrency(_order!.remainingBalance),
                  bold: true,
                  color: _order!.balancePaid
                      ? Colors.green.shade700
                      : (_order!.remainingBalance > 0 ? kError : Colors.green.shade700),
                ),
                if (_order!.balancePaid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Payment Complete',
                          style: AppTextStyles.labelSm.copyWith(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Footer ───────────────────────────────
                Center(
                  child: Text(
                    'Thank you for your business!',
                    style: AppTextStyles.bodySm.copyWith(
                      color: kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Darzi Pro — Professional Tailoring Management',
                    style: AppTextStyles.labelSm.copyWith(color: kTextSecondary.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceHeaderItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white60)),
        Text(value, style: AppTextStyles.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kPrimary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelLg),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySm.copyWith(color: kTextSecondary)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTextStyles.labelLg : AppTextStyles.bodyMd),
          Text(
            value,
            style: (bold ? AppTextStyles.labelLg : AppTextStyles.bodyMd).copyWith(
              color: color ?? (bold ? kTextPrimary : kTextSecondary),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: kPrimary.withOpacity(0.08)),
      );

  /// Formats a phone number cleanly — strips existing +92/92 prefix then adds +92 once
  String _formatPhone(String phone) {
    if (phone == '—' || phone.isEmpty) return phone;
    String cleaned = phone.trim()
        .replaceAll('+92', '')
        .replaceAll(RegExp(r'^92'), '')
        .trim();
    return '+92$cleaned';
  }

  void _shareWhatsApp() async {
    if (_customer == null || _order == null) return;
    final cleaned = cleanPhoneForWhatsApp(_customer!.phone);
    final msg = Uri.encodeComponent(
      'Assalamu Alaikum ${_customer!.name}!\n\n'
      '📋 *Invoice #${_order!.orderNumber}*\n'
      '👔 ${_order!.garmentType}\n'
      '📅 Delivery: ${formatDate(_order!.deliveryDate)}\n\n'
      '💰 *Payment Summary*\n'
      'Total: ${formatCurrency(_order!.totalAmount)}\n'
      'Deposit: ${formatCurrency(_order!.advancePaid)}\n'
      'Balance: ${formatCurrency(_order!.remainingBalance)}\n\n'
      '— ${HiveService.shopName ?? 'Darzi Pro'}',
    );
    final url = Uri.parse('whatsapp://send?phone=$cleaned&text=$msg');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.whatsappNotAvailable),
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
}


