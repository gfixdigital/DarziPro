import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/customer_provider.dart';
import '../../../models/customer.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_input.dart';

/// Step 1 — Order Info: Customer, dates, garment, pricing
class Step1Info extends StatefulWidget {
  final String? customerId;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? garmentType;
  final bool isUrgent;
  final double totalAmount;
  final double advancePaid;
  final String? fabricNotes;
  final Function(Map<String, dynamic>) onNext;

  const Step1Info({
    super.key,
    this.customerId,
    required this.orderDate,
    this.deliveryDate,
    this.garmentType,
    required this.isUrgent,
    required this.totalAmount,
    required this.advancePaid,
    this.fabricNotes,
    required this.onNext,
  });

  @override
  State<Step1Info> createState() => _Step1InfoState();
}

class _Step1InfoState extends State<Step1Info> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  late DateTime _orderDate;
  DateTime? _deliveryDate;
  String? _garmentType;
  int _quantity = 1;
  late bool _isUrgent;
  final _totalController = TextEditingController();
  final _advanceController = TextEditingController();
  final _fabricNotesController = TextEditingController();
  final _searchController = TextEditingController();
  bool _showSearch = false;

  // Garment types with icons
  final _garmentTypes = [
    {'label': AppStrings.kameezShalwar, 'icon': Icons.checkroom_outlined, 'desc': 'Traditional shalwar kameez'},
    {'label': AppStrings.waistcoat,     'icon': Icons.dry_cleaning_outlined, 'desc': 'Waistcoat / Jacket'},
    {'label': AppStrings.suit2Piece,    'icon': Icons.style_outlined, 'desc': 'Two-piece formal suit'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.customerId;
    _orderDate = widget.orderDate;
    _deliveryDate = widget.deliveryDate;
    if (widget.garmentType != null) {
      final match = RegExp(r'^(\d+)x (.+)$').firstMatch(widget.garmentType!);
      if (match != null) {
        _quantity = int.tryParse(match.group(1)!) ?? 1;
        _garmentType = match.group(2);
      } else {
        _garmentType = widget.garmentType;
        _quantity = 1;
      }
    }
    _isUrgent = widget.isUrgent;
    if (widget.totalAmount > 0) _totalController.text = widget.totalAmount.toStringAsFixed(0);
    if (widget.advancePaid > 0) _advanceController.text = widget.advancePaid.toStringAsFixed(0);
    _fabricNotesController.text = widget.fabricNotes ?? '';
  }

  @override
  void dispose() {
    _totalController.dispose();
    _advanceController.dispose();
    _fabricNotesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _balanceDue {
    final total = double.tryParse(_totalController.text) ?? 0;
    final advance = double.tryParse(_advanceController.text) ?? 0;
    return (total - advance).clamp(0, double.infinity);
  }

  Future<void> _pickDate(bool isDelivery) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isDelivery
          ? (_deliveryDate ?? _orderDate.add(const Duration(days: 7)))
          : _orderDate,
      firstDate: isDelivery ? _orderDate : DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => isDelivery ? _deliveryDate = date : _orderDate = date);
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectCustomer), backgroundColor: kError));
      return;
    }
    if (_garmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectGarment), backgroundColor: kError));
      return;
    }
    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectDeliveryDate), backgroundColor: kError));
      return;
    }
    widget.onNext({
      'customerId': _selectedCustomerId,
      'orderDate': _orderDate,
      'deliveryDate': _deliveryDate,
      'garmentType': '$_quantity' + 'x ' + _garmentType!,
      'isUrgent': _isUrgent,
      'totalAmount': double.tryParse(_totalController.text) ?? 0.0,
      'advancePaid': double.tryParse(_advanceController.text) ?? 0.0,
      'fabricNotes': _fabricNotesController.text.trim().isEmpty ? null : _fabricNotesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer ──────────────────────────────────────
            _sectionLabel(AppStrings.customer, Icons.person_outline),
            const SizedBox(height: 10),
            if (_selectedCustomerId != null) ...[
              _buildSelectedCustomer(customers),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _selectedCustomerId = null),
                icon: const Icon(Icons.swap_horiz, size: 16, color: kPrimary),
                label: Text(AppStrings.changeCustomer, style: AppTextStyles.labelLg.copyWith(color: kPrimary)),
              ),
            ] else ...[
              AppInput(
                label: AppStrings.searchCustomer,
                hint: AppStrings.typeNameOrPhone,
                controller: _searchController,
                prefix: const Icon(Icons.search, color: kTextSecondary, size: 20),
                onChanged: (v) {
                  customers.setSearchQuery(v);
                  setState(() => _showSearch = v.isNotEmpty);
                },
              ),
              if (_showSearch && customers.customers.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: kSurface, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorder.withOpacity(0.4)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.customers.length,
                    itemBuilder: (_, i) {
                      final c = customers.customers[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: kPrimary,
                          radius: 16,
                          child: Text(getInitials(c.name), style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
                        ),
                        title: Text(c.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(c.phone, style: AppTextStyles.bodySm),
                        onTap: () => setState(() {
                          _selectedCustomerId = c.id;
                          _showSearch = false;
                          _searchController.clear();
                          customers.setSearchQuery('');
                        }),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              DashedButton(
                text: AppStrings.createNewCustomer,
                icon: Icons.person_add_outlined,
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/customers/add');
                  if (result is Customer) setState(() => _selectedCustomerId = result.id);
                },
              ),
            ],
            const SizedBox(height: 20),

            // ── Dates ─────────────────────────────────────────
            _sectionLabel(AppStrings.dates, Icons.calendar_month_outlined),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _DateCard(
                label: AppStrings.orderDate,
                date: _orderDate,
                onTap: () => _pickDate(false),
              )),
              const SizedBox(width: 12),
              Expanded(child: _DateCard(
                label: AppStrings.deliveryDate,
                date: _deliveryDate,
                onTap: () => _pickDate(true),
                isRequired: true,
                isEmpty: _deliveryDate == null,
              )),
            ]),
            const SizedBox(height: 20),

            // ── Garment Type ─────────────────────────────────
            _sectionLabel(AppStrings.garmentType, Icons.checkroom_outlined),
            const SizedBox(height: 10),
            Column(
              children: _garmentTypes.map((type) {
                final isSelected = _garmentType == type['label'];
                return GestureDetector(
                  onTap: () => setState(() => _garmentType = type['label'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? kPrimary : kBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                      ] : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : kPrimaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            type['icon'] as IconData,
                            color: isSelected ? Colors.white : kPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type['label'] as String,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: isSelected ? Colors.white : kTextPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type['desc'] as String,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isSelected ? Colors.white.withOpacity(0.75) : kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : kBorder,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: kPrimary)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // ── Quantity ─────────────────────────────────────
            Row(
              children: [
                Text(AppStrings.quantity, style: AppTextStyles.labelLg),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$_quantity', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Urgent Order ─────────────────────────────────
            _UrgentToggle(
              isUrgent: _isUrgent,
              onChanged: (v) => setState(() => _isUrgent = v),
            ),
            const SizedBox(height: 20),

            // ── Pricing ──────────────────────────────────────
            _sectionLabel(AppStrings.pricing, Icons.payments_outlined),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: AppInput(
                label: AppStrings.totalPriceRs,
                hint: '0',
                controller: _totalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefix: Text('Rs.', style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary, fontWeight: FontWeight.w600)),
                validator: (v) => Validators.requiredNumeric(v, 'Total'),
                onChanged: (_) => setState(() {}),
              )),
              const SizedBox(width: 12),
              Expanded(child: AppInput(
                label: AppStrings.advanceRs,
                hint: '0',
                controller: _advanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefix: Text('Rs.', style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary, fontWeight: FontWeight.w600)),
                onChanged: (_) => setState(() {}),
              )),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _balanceDue > 0
                      ? [kError.withOpacity(0.08), kError.withOpacity(0.04)]
                      : [kPrimary.withOpacity(0.08), kPrimary.withOpacity(0.04)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _balanceDue > 0 ? kError.withOpacity(0.3) : kPrimary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      _balanceDue > 0 ? Icons.pending_outlined : Icons.check_circle_outline,
                      size: 18,
                      color: _balanceDue > 0 ? kError : kPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.balanceDue, style: AppTextStyles.labelLg),
                  ]),
                  Text(
                    formatCurrency(_balanceDue),
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _balanceDue > 0 ? kError : kPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────
            _sectionLabel(AppStrings.notes, Icons.notes_outlined),
            const SizedBox(height: 10),
            AppInput(
              label: AppStrings.fabricOrderNotes,
              hint: 'e.g. "Blue cotton, thin lining..."',
              controller: _fabricNotesController,
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            AppButton(text: AppStrings.saveOrder, icon: Icons.check, onPressed: _handleNext),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: kPrimary),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.labelLg),
      ],
    );
  }

  Widget _buildSelectedCustomer(CustomerProvider customers) {
    final customer = customers.getCustomerById(_selectedCustomerId!);
    if (customer == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
          child: Center(
            child: Text(getInitials(customer.name),
                style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(customer.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            Text(customer.phone, style: AppTextStyles.bodySm),
          ]),
        ),
        const Icon(Icons.check_circle, color: kPrimary, size: 22),
      ]),
    );
  }
}

// ── Date Card Widget ──────────────────────────────────────────
class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isRequired;
  final bool isEmpty;

  const _DateCard({
    required this.label,
    required this.date,
    required this.onTap,
    this.isRequired = false,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEmpty ? kError.withOpacity(0.05) : kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty ? kError.withOpacity(0.4) : kBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(color: kTextSecondary),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: isEmpty ? kError : kPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  date != null ? formatDate(date!) : 'Tap to select',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: date == null ? kTextSecondary : kTextPrimary,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Urgent Toggle Widget ──────────────────────────────────────
class _UrgentToggle extends StatelessWidget {
  final bool isUrgent;
  final ValueChanged<bool> onChanged;

  const _UrgentToggle({required this.isUrgent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isUrgent),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUrgent ? const Color(0xFFFFF8E1) : kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? kAccentGold : kBorder,
            width: isUrgent ? 2 : 1.5,
          ),
          boxShadow: isUrgent ? [
            BoxShadow(color: kAccentGold.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUrgent ? kAccentGold : kPrimaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.flash_on_rounded,
                color: isUrgent ? Colors.white : kTextSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.urgentOrder,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isUrgent ? kAccentGold : kTextPrimary,
                    ),
                  ),
                  Text(
                    isUrgent ? 'Rush delivery — marked in gold' : 'Toggle for priority handling',
                    style: AppTextStyles.labelSm.copyWith(
                      color: isUrgent ? kAccentGold.withOpacity(0.8) : kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isUrgent,
              activeColor: kAccentGold,
              activeTrackColor: kAccentGold.withOpacity(0.3),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
