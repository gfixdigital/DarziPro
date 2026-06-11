/// Form Validators for Darzi Pro

class Validators {
  Validators._();

  /// Validates required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates phone number (Pakistani format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10 || cleaned.length > 12) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional numeric fields
    }
    final num? parsed = num.tryParse(value);
    if (parsed == null) {
      return '$fieldName must be a number';
    }
    if (parsed < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates required numeric input
  static String? requiredNumeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num? parsed = num.tryParse(value);
    if (parsed == null) {
      return '$fieldName must be a number';
    }
    if (parsed <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validates that delivery date is after order date
  static String? deliveryDate(DateTime? delivery, DateTime? order) {
    if (delivery == null) {
      return 'Delivery date is required';
    }
    if (order != null && delivery.isBefore(order)) {
      return 'Delivery date must be after order date';
    }
    return null;
  }

  /// Validates advance is not more than total
  static String? advance(double? advance, double? total) {
    if (advance == null) return null;
    if (total != null && advance > total) {
      return 'Advance cannot exceed total amount';
    }
    return null;
  }
}
