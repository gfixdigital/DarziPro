import 'package:intl/intl.dart';
import '../services/hive_service.dart';
import '../constants/strings.dart';

/// Currency formatter — PKR (Rs.)
String formatCurrency(double amount) {
  final formatter = NumberFormat('#,###', 'en_PK');
  return 'Rs. ${formatter.format(amount.round())}';
}

/// Date formatter — dd MMM yyyy (e.g. 02 Jun 2026)
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Short date formatter — dd/MM
String formatDateShort(DateTime date) {
  return DateFormat('dd/MM').format(date);
}
/// Time-based greeting
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return AppStrings.goodMorning;
  if (hour < 17) return AppStrings.goodAfternoon;
  return AppStrings.goodEvening;
}

/// Calculates if an order is overdue
bool isOverdue(DateTime deliveryDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final delivery = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);
  return delivery.isBefore(today);
}

/// Calculates if delivery is today
bool isDueToday(DateTime deliveryDate) {
  final now = DateTime.now();
  return deliveryDate.year == now.year &&
      deliveryDate.month == now.month &&
      deliveryDate.day == now.day;
}

/// Cleans phone number for WhatsApp
String cleanPhoneForWhatsApp(String phone) {
  String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (cleaned.startsWith('0')) {
    cleaned = '92${cleaned.substring(1)}';
  } else if (!cleaned.startsWith('92')) {
    cleaned = '92$cleaned';
  }
  return cleaned;
}

/// Gets initials from a name (2 letters max)
String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
