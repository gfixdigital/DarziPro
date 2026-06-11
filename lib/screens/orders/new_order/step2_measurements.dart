import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/hive_service.dart';
import '../../../models/measurement.dart';
import '../../../widgets/common/app_button.dart';

class Step2Measurements extends StatefulWidget {
  final String? customerId;
  final Measurement measurement;
  final Function(Measurement) onNext;
  final VoidCallback onBack;

  const Step2Measurements({
    super.key,
    this.customerId,
    required this.measurement,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2Measurements> createState() => _Step2MeasurementsState();
}

class _Step2MeasurementsState extends State<Step2Measurements> {
  final _controllers = <String, TextEditingController>{};
  final _fitNotesController = TextEditingController();

  final _fields = [
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
    for (final key in _fieldKeys.keys) {
      _controllers[key] = TextEditingController();
    }
    // Load customer's saved measurements as the base (pre-fill)
    _loadPreviousMeasurements();
    // Then overlay with any order-specific values (only non-null overrides)
    _loadCurrentValues();
  }

  void _loadPreviousMeasurements() {
    if (widget.customerId == null) return;
    final prev = HiveService.getLatestMeasurementForCustomer(widget.customerId!);
    if (prev == null) return;
    final map = prev.displayMap;
    for (final entry in map.entries) {
      if (entry.value != null && _controllers.containsKey(entry.key)) {
        _controllers[entry.key]!.text = entry.value!.toString();
      }
    }
  }

  void _loadCurrentValues() {
    final m = widget.measurement;
    final map = m.displayMap;
    for (final entry in map.entries) {
      if (entry.value != null && _controllers.containsKey(entry.key)) {
        _controllers[entry.key]!.text = entry.value!.toString();
      }
    }
    _fitNotesController.text = m.fitNotes ?? '';
  }

  Measurement _buildMeasurement() {
    double? parse(String key) {
      final text = _controllers[key]?.text;
      if (text == null || text.isEmpty) return null;
      return double.tryParse(text);
    }

    return Measurement(
      id: widget.measurement.id,
      orderId: widget.measurement.orderId,
      shopId: widget.measurement.shopId,
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
      fitNotes: _fitNotesController.text.trim().isEmpty
          ? null
          : _fitNotesController.text.trim(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _fitNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.addMeasurements, style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(AppStrings.measurementsSubtitle, style: AppTextStyles.bodySm),
          const SizedBox(height: 20),
          ..._fields.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildField(row[0])),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(row[1])),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(AppStrings.fitNotes, style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fitNotesController,
            maxLines: 3,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'Any special fit requirements...',
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: kTextSecondary.withOpacity(0.5),
              ),
              filled: true,
              fillColor: kPrimaryLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBorder.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBorder.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kPrimary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: AppStrings.back,
                  isOutlined: true,
                  onPressed: widget.onBack,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: AppStrings.nextDetails,
                  onPressed: () => widget.onNext(_buildMeasurement()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSm),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controllers[label],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'in',
            suffixStyle: AppTextStyles.bodySm,
            filled: true,
            fillColor: kPrimaryLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorder.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorder.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
