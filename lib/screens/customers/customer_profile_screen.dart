import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/services/hive_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/sync_provider.dart';
import '../../models/customer.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/common/sync_indicator.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String customerId;
  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _editingMeasurements = false;
  final _measurementControllers = <String, TextEditingController>{};
  final _fitNotesController = TextEditingController();
  bool _savingMeasurements = false;

  final _measurementFields = [
    ['Kameez Length', 'Sleeve'],
    ['Shoulder', 'Neck'],
    ['Chest', 'Waist'],
    ['Hem', 'Shalwar Length'],
    ['Leg Opening', 'Cuff'],
  ];

  final _fieldKeys = {
    'Kameez Length': 'kameezLength',
    'Sleeve': 'sleeve',
    'Shoulder': 'shoulder',
    'Neck': 'neck',
    'Chest': 'chest',
    'Waist': 'waist',
    'Hem': 'hem',
    'Shalwar Length': 'shalwarLength',
    'Leg Opening': 'legOpening',
    'Cuff': 'cuff',
  };

  @override
  void initState() {
    super.initState();
    for (final row in _measurementFields) {
      for (final field in row) {
        _measurementControllers[field] = TextEditingController();
      }
    }
    _loadExistingMeasurements();
  }

  void _loadExistingMeasurements() {
    final m = HiveService.getLatestMeasurementForCustomer(widget.customerId);
    if (m == null) return;
    final map = m.displayMap;
    for (final entry in map.entries) {
      if (entry.value != null && _measurementControllers.containsKey(entry.key)) {
        _measurementControllers[entry.key]!.text = entry.value!.toString();
      }
    }
    _fitNotesController.text = m.fitNotes ?? '';
  }

  @override
  void dispose() {
    for (final c in _measurementControllers.values) c.dispose();
    _fitNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurements() async {
    setState(() => _savingMeasurements = true);

    double? parse(String key) {
      final t = _measurementControllers[key]?.text;
      return (t == null || t.isEmpty) ? null : double.tryParse(t);
    }

    try {
      final shopId = HiveService.shopId ?? '';
      // Check if a customer-default measurement already exists
      final existing = HiveService.getLatestMeasurementForCustomer(widget.customerId);
      final id = (existing?.orderId.startsWith('customer_default_') == true)
          ? existing!.id
          : const Uuid().v4();

      final m = Measurement(
        id: id,
        orderId: '',
        shopId: shopId,
        kameezLength: parse('Kameez Length'),
        sleeve: parse('Sleeve'),
        shoulder: parse('Shoulder'),
        neck: parse('Neck'),
        hem: parse('Hem'),
        chest: parse('Chest'),
        waist: parse('Waist'),
        shalwarLength: parse('Shalwar Length'),
        legOpening: parse('Leg Opening'),
        cuff: parse('Cuff'),
        fitNotes: _fitNotesController.text.trim().isEmpty ? null : _fitNotesController.text.trim(),
      );

      await HiveService.saveCustomerDefaultMeasurement(widget.customerId, m);

      setState(() {
        _savingMeasurements = false;
        _editingMeasurements = false;
      });

      if (mounted) {
        context.read<SyncProvider>().syncNow();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.measurementsSaved), backgroundColor: kPrimary),
        );
      }
    } catch (e) {
      setState(() => _savingMeasurements = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: kError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerProvider>().getCustomerById(widget.customerId);
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.notFound)),
        body: Center(child: Text(AppStrings.customerNotFound)),
      );
    }

    final orders = context.watch<OrderProvider>().getOrdersForCustomer(widget.customerId);
    final measurement = HiveService.getLatestMeasurementForCustomer(widget.customerId);
    final style = HiveService.getCustomerDefaultStyle(widget.customerId);

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          const SyncIndicator(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: kBackground,
                  foregroundColor: kTextPrimary,
                  elevation: 0,
                  pinned: true,
                  title: Text(AppStrings.customerProfile, style: AppTextStyles.headlineSm),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer header card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    getInitials(customer.name),
                                    style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer.name,
                                        style: AppTextStyles.bodyLg.copyWith(
                                            fontWeight: FontWeight.w700, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.phone_outlined, size: 14, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(customer.phone,
                                          style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
                                    ]),
                                    if (customer.address != null && customer.address!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(customer.address!,
                                              style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ]),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${orders.length}',
                                    style: AppTextStyles.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                  Text(AppStrings.orders, style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Measurements section
                        _buildMeasurementsSection(measurement),
                        const SizedBox(height: 16),
                        
                        // Style Preferences section
                        if (style != null) ...[
                          _buildStyleSection(style),
                          const SizedBox(height: 16),
                        ],

                        // Notes
                        Builder(
                          builder: (context) {
                            final displayNotes = HiveService.getDisplayNotes(customer.notes);
                            if (displayNotes.isEmpty) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kPrimaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kPrimary.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.notes_outlined, size: 16, color: kPrimary),
                                      const SizedBox(width: 6),
                                      Text(AppStrings.notes, style: AppTextStyles.labelLg),
                                    ]),
                                    const SizedBox(height: 8),
                                    Text(displayNotes, style: AppTextStyles.bodyMd),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),

                        // Order History
                        Text(AppStrings.orderHistory, style: AppTextStyles.headlineSm),
                        const SizedBox(height: 12),
                        if (orders.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(children: [
                                const Icon(Icons.receipt_long_outlined, size: 40, color: kTextSecondary),
                                const SizedBox(height: 12),
                                Text(AppStrings.noOrdersYet, style: AppTextStyles.bodySm),
                              ]),
                            ),
                          )
                        else
                          ...orders.map((order) => _buildOrderHistoryItem(context, order)),
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

  Widget _buildMeasurementsSection(Measurement? measurement) {
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
              Row(children: [
                const Icon(Icons.straighten_outlined, size: 18, color: kPrimary),
                const SizedBox(width: 8),
                Text(AppStrings.savedMeasurements, style: AppTextStyles.labelLg),
              ]),
              TextButton.icon(
                onPressed: () => setState(() => _editingMeasurements = !_editingMeasurements),
                icon: Icon(_editingMeasurements ? Icons.close : Icons.edit_outlined, size: 16),
                label: Text(_editingMeasurements ? 'Cancel' : 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: kPrimary,
                  textStyle: AppTextStyles.labelLg,
                ),
              ),
            ],
          ),
          if (_editingMeasurements) ...[
            const Divider(height: 20),
            ..._measurementFields.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Expanded(child: _editField(row[0])),
                const SizedBox(width: 12),
                Expanded(child: _editField(row[1])),
              ]),
            )),
            const SizedBox(height: 8),
            Text(AppStrings.fitNotes, style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _fitNotesController,
              maxLines: 2,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'e.g. "Loose at shoulders..."',
                hintStyle: AppTextStyles.bodyMd.copyWith(color: kTextSecondary.withOpacity(0.5)),
                filled: true, fillColor: kBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Save Measurements',
              icon: Icons.check,
              isLoading: _savingMeasurements,
              onPressed: _saveMeasurements,
            ),
          ] else if (measurement != null) ...[
            const Divider(height: 20),
            _buildMeasurementGrid(measurement),
            if (measurement.fitNotes != null && measurement.fitNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 14, color: kPrimary),
                  const SizedBox(width: 6),
                  Flexible(child: Text(measurement.fitNotes!, style: AppTextStyles.bodySm)),
                ]),
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _editingMeasurements = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimary.withOpacity(0.2), style: BorderStyle.solid),
                ),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_circle_outline, color: kPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(AppStrings.tapToAddMeasurements, style: AppTextStyles.bodyMd.copyWith(color: kPrimary)),
                  ]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementGrid(Measurement m) {
    final entries = m.displayMap.entries.where((e) => e.value != null).toList();
    if (entries.isEmpty) return const SizedBox();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 3.2,
        crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final e = entries[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(e.key, style: AppTextStyles.labelSm.copyWith(color: kTextSecondary), overflow: TextOverflow.ellipsis)),
              Text('${e.value}"', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700, color: kPrimary)),
            ],
          ),
        );
      },
    );
  }

  Widget _editField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: _measurementControllers[label],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '—',
            suffixText: '"',
            suffixStyle: AppTextStyles.bodyMd.copyWith(color: kPrimary, fontWeight: FontWeight.w700),
            filled: true, fillColor: kBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSection(StylePreference style) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.style_outlined, size: 18, color: kPrimary),
              const SizedBox(width: 8),
              Text(AppStrings.step3Title, style: AppTextStyles.labelLg),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (style.collar != null && style.collar!.isNotEmpty) _styleChip('Collar: ${style.collar}'),
              if (style.pockets.isNotEmpty) _styleChip('Pockets: ${style.pockets.join(", ")}'),
              if (style.daman != null && style.daman!.isNotEmpty) _styleChip('Daman: ${style.daman}'),
              if (style.cuffs != null && style.cuffs!.isNotEmpty) _styleChip('Cuffs: ${style.cuffs}'),
              if (style.silkThread) _styleChip('Silk Thread'),
              if (style.stitching != null && style.stitching!.isNotEmpty) _styleChip('Stitching: ${style.stitching}'),
              if (style.buttons != null && style.buttons!.isNotEmpty) _styleChip('Buttons: ${style.buttons}'),
              if (style.suitStyle.isNotEmpty) _styleChip('Suit Style: ${style.suitStyle.join(", ")}'),
              if (style.shalwarStyle != null && style.shalwarStyle!.isNotEmpty) _styleChip('Shalwar: ${style.shalwarStyle}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _styleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.05),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: AppTextStyles.bodySm.copyWith(color: kPrimary)),
    );
  }

  Widget _buildOrderHistoryItem(BuildContext context, order) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimary.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            if (order.isUrgent)
              Container(
                width: 3, height: 48,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: kAccentGold, borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${order.orderNumber}', style: AppTextStyles.labelLg.copyWith(color: kPrimary)),
                      StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(order.garmentType, style: AppTextStyles.bodySm),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppStrings.orderDate}: ${formatDate(order.orderDate)}', style: AppTextStyles.labelSm, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${AppStrings.due}: ${formatDate(order.deliveryDate)}', style: AppTextStyles.labelSm.copyWith(color: kError, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Text(formatCurrency(order.totalAmount), style: AppTextStyles.labelLg),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: kPrimary),
          ],
        ),
      ),
    );
  }
}
