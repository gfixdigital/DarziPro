import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

/// Custom input field — kPrimaryLight background, 2px kPrimary bottom border on focus
class AppInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSm.copyWith(
              color: kTextSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            focusNode: focusNode,
            autofocus: autofocus,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: kTextSecondary.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: prefix,
                    )
                  : null,
              prefixIconConstraints: prefix != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: kBorder.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: kBorder.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: kPrimary,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: kError,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: kError,
                  width: 2.5,
                ),
              ),
              errorStyle: AppTextStyles.labelSm.copyWith(color: kError),
            ),
          ),
        ),
      ],
    );
  }
}
