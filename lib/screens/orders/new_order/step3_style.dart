import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/strings.dart';
import '../../../models/style_preference.dart';
import '../../../widgets/common/app_button.dart';

class Step3Style extends StatefulWidget {
  final StylePreference stylePreference;
  final Function(StylePreference) onSave;
  final VoidCallback onBack;

  const Step3Style({
    super.key,
    required this.stylePreference,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<Step3Style> createState() => _Step3StyleState();
}

class _Step3StyleState extends State<Step3Style> {
  String? _collar;
  List<String> _pockets = [];
  String? _daman;
  String? _cuffs;
  bool _silkThread = false;
  String? _stitching;
  String? _buttons;
  List<String> _suitStyle = [];
  String? _shalwarStyle;

  @override
  void initState() {
    super.initState();
    final sp = widget.stylePreference;
    _collar = sp.collar;
    _pockets = List.from(sp.pockets);
    _daman = sp.daman;
    _cuffs = sp.cuffs;
    _silkThread = sp.silkThread;
    _stitching = sp.stitching;
    _buttons = sp.buttons;
    _suitStyle = List.from(sp.suitStyle);
    _shalwarStyle = sp.shalwarStyle;
  }

  StylePreference _buildStyle() {
    return StylePreference(
      id: widget.stylePreference.id,
      orderId: widget.stylePreference.orderId,
      shopId: widget.stylePreference.shopId,
      collar: _collar,
      pockets: _pockets,
      daman: _daman,
      cuffs: _cuffs,
      silkThread: _silkThread,
      stitching: _stitching,
      buttons: _buttons,
      suitStyle: _suitStyle,
      shalwarStyle: _shalwarStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.step3Title, style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(AppStrings.selectStyleOptions,
              style: AppTextStyles.bodySm),
          const SizedBox(height: 20),
          _buildSection('Collar', ['Half Ban', 'Full Ban', 'Collar'],
              _collar, (v) => setState(() => _collar = v)),
          _buildMultiSection('Pockets',
              ['Front Pocket', 'Single Side Pocket', 'Double Pocket', 'Shalwar Pocket'],
              _pockets, (v) => setState(() => _pockets = v)),
          _buildSection('Daman', ['Round Daman', 'Square Daman'],
              _daman, (v) => setState(() => _daman = v)),
          _buildSection('Cuffs', ['Simple Cuff', 'Fitted Cuff', 'Round Sleeve'],
              _cuffs, (v) => setState(() => _cuffs = v)),
          // Silk Thread toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.silkThread, style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip('Yes', _silkThread, () => setState(() => _silkThread = true)),
                    const SizedBox(width: 8),
                    _chip('No', !_silkThread, () => setState(() => _silkThread = false)),
                  ],
                ),
              ],
            ),
          ),
          _buildSection('Stitching', ['Single', 'Double', 'Triple'],
              _stitching, (v) => setState(() => _stitching = v)),
          _buildSection('Buttons', ['English', 'Tich', 'Colour', 'Stud Hole'],
              _buttons, (v) => setState(() => _buttons = v)),
          _buildMultiSection('Suit Style Features',
              ['Designer Suit', 'Sleeve Pleat', 'Hidden Pocket'],
              _suitStyle, (v) => setState(() => _suitStyle = v)),
          _buildSection('Shalwar Style', ['Balochi', 'Normal', 'Trouser'],
              _shalwarStyle, (v) => setState(() => _shalwarStyle = v)),
          const SizedBox(height: 12),
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
                  text: AppStrings.saveOrder,
                  icon: Icons.check,
                  onPressed: () => widget.onSave(_buildStyle()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String? selected,
      ValueChanged<String> onSelect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((o) => _chip(o, selected == o, () => onSelect(o)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSection(String title, List<String> options,
      List<String> selected, ValueChanged<List<String>> onUpdate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLg),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((o) {
              final isSelected = selected.contains(o);
              return _chip(o, isSelected, () {
                final updated = List<String>.from(selected);
                isSelected ? updated.remove(o) : updated.add(o);
                onUpdate(updated);
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kPrimary : kBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: isSelected ? Colors.white : kTextPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
