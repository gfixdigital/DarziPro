import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

/// Add Customer Screen — 3 tabs: Info → Measurements → Style Preferences
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // ─── Personal Info ────────────────────────────────────────
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // ─── Measurements ─────────────────────────────────────────
  final _measurementControllers = <String, TextEditingController>{};
  final _fitNotesController = TextEditingController();
  final _measurementFields = [
    ['Kameez Length', 'Sleeve'],
    ['Shoulder', 'Neck'],
    ['Chest', 'Waist'],
    ['Hem', 'Shalwar Length'],
    ['Leg Opening', 'Cuff'],
  ];

  // ─── Style Preferences ────────────────────────────────────
  String? _collar;
  List<String> _pockets = [];
  String? _daman;
  String? _cuffs;
  bool _silkThread = false;
  String? _stitching;
  String? _buttons;
  List<String> _suitStyle = [];
  String? _shalwarStyle;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    for (final row in _measurementFields) {
      for (final field in row) {
        _measurementControllers[field] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _fitNotesController.dispose();
    for (final c in _measurementControllers.values) c.dispose();
    super.dispose();
  }

  Map<String, double?> _getMeasurementValues() {
    double? parse(String key) {
      final t = _measurementControllers[key]?.text;
      return (t == null || t.isEmpty) ? null : double.tryParse(t);
    }
    return {
      'kameezLength': parse('Kameez Length'),
      'sleeve': parse('Sleeve'),
      'shoulder': parse('Shoulder'),
      'neck': parse('Neck'),
      'chest': parse('Chest'),
      'waist': parse('Waist'),
      'hem': parse('Hem'),
      'shalwarLength': parse('Shalwar Length'),
      'legOpening': parse('Leg Opening'),
      'cuff': parse('Cuff'),
    };
  }

  Map<String, dynamic> _getStyleValues() => {
    'collar': _collar,
    'pockets': _pockets,
    'daman': _daman,
    'cuffs': _cuffs,
    'silkThread': _silkThread,
    'stitching': _stitching,
    'buttons': _buttons,
    'suitStyle': _suitStyle,
    'shalwarStyle': _shalwarStyle,
  };

  bool _validateInfoTab() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterCustomerName), backgroundColor: kError),
      );
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterPhone), backgroundColor: kError),
      );
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validateInfoTab()) {
      _tabController.animateTo(0);
      return;
    }
    setState(() => _isLoading = true);
    // Normalize phone: strip any +92 prefix before saving
    final rawPhone = _phoneController.text.trim();
    final cleanPhone = rawPhone
        .replaceAll('+92', '')
        .replaceAll(RegExp(r'^92'), '')
        .replaceAll(RegExp(r'^0'), '')
        .trim();
    try {
      await context.read<CustomerProvider>().addCustomer(
            name: _nameController.text.trim(),
            phone: cleanPhone,
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            measurements: _getMeasurementValues(),
            fitNotes: _fitNotesController.text.trim().isEmpty ? null : _fitNotesController.text.trim(),
            stylePreferences: _getStyleValues(),
          );
      // Trigger sync immediately
      if (mounted) context.read<SyncProvider>().syncNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.customerAddedSuccess), backgroundColor: kPrimary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        foregroundColor: kTextPrimary,
        elevation: 0,
        title: Text(AppStrings.addNewCustomer, style: AppTextStyles.headlineSm),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimary,
          indicatorWeight: 3,
          labelColor: kPrimary,
          unselectedLabelColor: kTextSecondary,
          labelStyle: AppTextStyles.labelLg,
          unselectedLabelStyle: AppTextStyles.bodyMd,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Info'),
            Tab(icon: Icon(Icons.straighten_outlined, size: 20), text: 'Measurements'),
            Tab(icon: Icon(Icons.style_outlined, size: 20), text: 'Style'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildInfoTab(),
            _buildMeasurementsTab(),
            _buildStyleTab(),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Info ───────────────────────────────────────────
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(title: 'Personal Details', icon: Icons.badge_outlined, children: [
            AppInput(
              label: 'Full Name *',
              hint: 'Enter customer name',
              controller: _nameController,
              validator: (v) => Validators.required(v, 'Name'),
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Phone Number *',
              hint: '3XX XXXXXXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              prefix: Text('+92 ', style: AppTextStyles.bodyMd.copyWith(color: kPrimary, fontWeight: FontWeight.w600)),
              validator: Validators.phone,
            ),
          ]),
          const SizedBox(height: 16),
          _card(title: 'Address & Notes', icon: Icons.location_on_outlined, children: [
            AppInput(label: 'Address', hint: 'Street, area, city...', controller: _addressController, maxLines: 2),
            const SizedBox(height: 16),
            AppInput(label: 'Notes', hint: 'Any preferences or notes...', controller: _notesController, maxLines: 3),
          ]),
          const SizedBox(height: 28),
          AppButton(
            text: 'Next: Measurements →',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (_validateInfoTab()) _tabController.animateTo(1);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Tab 2: Measurements ──────────────────────────────────
  Widget _buildMeasurementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kPrimary.withOpacity(0.15)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 18, color: kPrimary),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'All measurements in inches. Fill what you know — you can update later.',
                style: AppTextStyles.bodySm.copyWith(color: kPrimary),
              )),
            ]),
          ),
          const SizedBox(height: 20),
          ..._measurementFields.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(child: _measurementField(row[0])),
              const SizedBox(width: 12),
              Expanded(child: _measurementField(row[1])),
            ]),
          )),
          const SizedBox(height: 8),
          Text(AppStrings.fitNotes, style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fitNotesController,
            maxLines: 3,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'e.g. "Loose at shoulders, tight waist..."',
              hintStyle: AppTextStyles.bodyMd.copyWith(color: kTextSecondary.withOpacity(0.5)),
              filled: true,
              fillColor: kSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 2)),
            ),
          ),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: AppButton(text: '← Back', isOutlined: true, onPressed: () => _tabController.animateTo(0))),
            const SizedBox(width: 12),
            Expanded(child: AppButton(text: 'Next: Style →', icon: Icons.arrow_forward, onPressed: () => _tabController.animateTo(2))),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _measurementField(String label) {
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
            filled: true,
            fillColor: kSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 2)),
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Style Preferences ─────────────────────────────
  Widget _buildStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _styleCard(
                  'Collar Style',
                  Icons.crop_16_9_outlined,
                  ['Half Ban', 'Full Ban', 'Collar'],
                  _collar,
                  (v) => setState(() => _collar = v == _collar ? null : v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _styleCard(
                  'Daman (Hem)',
                  Icons.expand_more_rounded,
                  ['Round Daman', 'Square Daman'],
                  _daman,
                  (v) => setState(() => _daman = v == _daman ? null : v),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _styleCard(
                  'Cuffs',
                  Icons.front_hand_outlined,
                  ['Simple Cuff', 'Fitted Cuff', 'Round Sleeve'],
                  _cuffs,
                  (v) => setState(() => _cuffs = v == _cuffs ? null : v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _styleCard(
                  'Stitching',
                  Icons.linear_scale,
                  ['Single', 'Double', 'Triple'],
                  _stitching,
                  (v) => setState(() => _stitching = v == _stitching ? null : v),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _styleCard(
                  'Buttons',
                  Icons.radio_button_checked,
                  ['English', 'Tich', 'Colour', 'Stud Hole'],
                  _buttons,
                  (v) => setState(() => _buttons = v == _buttons ? null : v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _styleCard(
                  'Shalwar Style',
                  Icons.vertical_split_outlined,
                  ['Balochi', 'Normal', 'Trouser'],
                  _shalwarStyle,
                  (v) => setState(() => _shalwarStyle = v == _shalwarStyle ? null : v),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _multiStyleCard(
                  'Pockets',
                  Icons.inventory_2_outlined,
                  ['Front Pocket', 'Single Side', 'Double Pocket', 'Shalwar Pocket'],
                  _pockets,
                  (v) => setState(() => _pockets = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _multiStyleCard(
                  'Suit Features',
                  Icons.auto_awesome_outlined,
                  ['Designer Suit', 'Sleeve Pleat', 'Hidden Pocket'],
                  _suitStyle,
                  (v) => setState(() => _suitStyle = v),
                ),
              ),
            ],
          ),
          // Silk Thread Toggle Card
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary.withOpacity(0.08)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.auto_fix_high_outlined, size: 18, color: kPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.silkThread, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                Text(AppStrings.premiumEmbroidery, style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
              ])),
              Switch(value: _silkThread, activeColor: kPrimary, onChanged: (v) => setState(() => _silkThread = v)),
            ]),
          ),
          Row(children: [
            Expanded(child: AppButton(text: '← Back', isOutlined: true, onPressed: () => _tabController.animateTo(1))),
            const SizedBox(width: 12),
            Expanded(child: AppButton(
              text: 'Save Customer',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _save,
            )),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Style Card Builders ───────────────────────────────────
  Widget _styleCard(
    String title,
    IconData icon,
    List<String> options,
    String? selected,
    ValueChanged<String> onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: kPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: AppTextStyles.labelLg, overflow: TextOverflow.ellipsis)),
            if (selected != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onTap(selected),
                child: Text(AppStrings.clear, style: const TextStyle(color: kTextSecondary, fontSize: 11)),
              ),
            ],
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSel = selected == opt;
              return GestureDetector(
                onTap: () => onTap(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? kPrimary : kBorder, width: 1.5),
                  ),
                  child: Text(
                    opt,
                    style: AppTextStyles.bodySm.copyWith(
                      color: isSel ? Colors.white : kTextPrimary,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _multiStyleCard(
    String title,
    IconData icon,
    List<String> options,
    List<String> selected,
    ValueChanged<List<String>> onUpdate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: kPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: AppTextStyles.labelLg, overflow: TextOverflow.ellipsis)),
            if (selected.isNotEmpty) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
                child: Text('${selected.length}', style: AppTextStyles.labelSm.copyWith(color: Colors.white, fontSize: 10)),
              ),
            ],
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSel = selected.contains(opt);
              return GestureDetector(
                onTap: () {
                  final updated = List<String>.from(selected);
                  isSel ? updated.remove(opt) : updated.add(opt);
                  onUpdate(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? kPrimary : kBorder, width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      opt,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isSel ? Colors.white : kTextPrimary,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (isSel) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, size: 12, color: Colors.white),
                    ],
                  ]),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _card({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: kPrimary),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTextStyles.labelLg),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
