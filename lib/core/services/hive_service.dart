import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/customer.dart';
import '../../models/order.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';

/// Hive local storage service
/// All reads come from Hive first (instant, no loading)
class HiveService {
  static const String customersBox = 'customers';
  static const String ordersBox = 'orders';
  static const String measurementsBox = 'measurements';
  static const String stylePreferencesBox = 'style_preferences';
  static const String settingsBox = 'settings';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(MeasurementAdapter());
    Hive.registerAdapter(StylePreferenceAdapter());

    // Open boxes
    await Hive.openBox<Customer>(customersBox);
    await Hive.openBox<Order>(ordersBox);
    await Hive.openBox<Measurement>(measurementsBox);
    await Hive.openBox<StylePreference>(stylePreferencesBox);
    await Hive.openBox(settingsBox);
  }

  // ─── Settings ────────────────────────────────────────────
  static Box get settings => Hive.box(settingsBox);

  static String? get shopId => settings.get('shop_id') as String?;
  static set shopId(String? value) => settings.put('shop_id', value);

  static String get language => settings.get('language', defaultValue: 'en') as String;
  static set language(String value) => settings.put('language', value);

  static String? get shopName => settings.get('shop_name') as String?;
  static set shopName(String? value) => settings.put('shop_name', value);

  static String? get ownerName => settings.get('owner_name') as String?;
  static set ownerName(String? value) => settings.put('owner_name', value);

  static String? get contactNumber => settings.get('contact_number') as String?;
  static set contactNumber(String? value) => settings.put('contact_number', value);

  static String? get authToken => settings.get('auth_token') as String?;
  static set authToken(String? value) => settings.put('auth_token', value);

  static DateTime? get lastSyncTime {
    final val = settings.get('last_sync_time');
    return val is DateTime ? val : null;
  }

  static set lastSyncTime(DateTime? value) =>
      settings.put('last_sync_time', value);

  static bool get newOrderAlerts => settings.get('new_order_alerts', defaultValue: true) as bool;
  static set newOrderAlerts(bool value) => settings.put('new_order_alerts', value);

  static bool get measurementReminders => settings.get('measurement_reminders', defaultValue: true) as bool;
  static set measurementReminders(bool value) => settings.put('measurement_reminders', value);

  static bool get dailySummary => settings.get('daily_summary', defaultValue: false) as bool;
  static set dailySummary(bool value) => settings.put('daily_summary', value);

  static bool get hasSeenAndroidPrompt => settings.get('has_seen_android_prompt', defaultValue: false) as bool;
  static set hasSeenAndroidPrompt(bool value) => settings.put('has_seen_android_prompt', value);

  // ─── Customers ───────────────────────────────────────────
  static Box<Customer> get customersBoxInstance =>
      Hive.box<Customer>(customersBox);

  static List<Customer> getActiveCustomers() {
    return customersBoxInstance.values
        .where((c) => !c.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Customer? getCustomerById(String id) {
    try {
      return customersBoxInstance.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCustomer(Customer customer) async {
    await customersBoxInstance.put(customer.id, customer);
  }

  // ─── Orders ──────────────────────────────────────────────
  static Box<Order> get ordersBoxInstance => Hive.box<Order>(ordersBox);

  static List<Order> getActiveOrders() {
    return ordersBoxInstance.values
        .where((o) => !o.isDeleted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Order> getOrdersByStatus(String status) {
    return ordersBoxInstance.values
        .where((o) => !o.isDeleted && o.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Order> getOrdersForCustomer(String customerId) {
    return ordersBoxInstance.values
        .where((o) => !o.isDeleted && o.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Order? getOrderById(String id) {
    try {
      return ordersBoxInstance.values.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveOrder(Order order) async {
    await ordersBoxInstance.put(order.id, order);
  }

  /// ⚠️ CRITICAL FIX: Generate order number scoped to THIS shop only,
  /// using max existing number to avoid collisions when syncing from cloud.
  /// This prevents duplicate #ORD-002 when orders are pulled from Supabase.
  static String generateOrderNumber() {
    final shopOrders = ordersBoxInstance.values
        .where((o) => !o.isDeleted && o.shopId == (shopId ?? ''))
        .toList();

    // Find the highest existing order number to avoid collisions
    int maxNum = 0;
    for (final order in shopOrders) {
      final numStr = order.orderNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final num = int.tryParse(numStr) ?? 0;
      if (num > maxNum) maxNum = num;
    }

    final nextNum = maxNum + 1;
    return 'ORD-${nextNum.toString().padLeft(3, '0')}';
  }

  // ─── Measurements ────────────────────────────────────────
  static Box<Measurement> get measurementsBoxInstance =>
      Hive.box<Measurement>(measurementsBox);

  static Measurement? getMeasurementForOrder(String orderId) {
    try {
      return measurementsBoxInstance.values
          .firstWhere((m) => m.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  static Measurement? getLatestMeasurementForCustomer(String customerId) {
    // First check the customer-level default measurement
    final defaultKey = 'customer_default_$customerId';
    try {
      final defM = measurementsBoxInstance.values
          .firstWhere((m) => m.orderId == defaultKey);
      return defM;
    } catch (_) {}
    // Fallback: find from orders
    final customerOrders = getOrdersForCustomer(customerId);
    if (customerOrders.isEmpty) return null;
    for (final order in customerOrders) {
      final measurement = getMeasurementForOrder(order.id);
      if (measurement != null) return measurement;
    }
    return null;
  }

  static String getDisplayNotes(String? notes) {
    if (notes == null) return '';
    final index = notes.indexOf('###METADATA###');
    if (index == -1) return notes;
    return notes.substring(0, index).trim();
  }

  static Map<String, dynamic>? getMetadataJson(String? notes, String key) {
    if (notes == null) return null;
    final start = notes.indexOf('###METADATA###');
    if (start == -1) return null;
    final end = notes.indexOf('###END_METADATA###', start);
    if (end == -1) return null;

    final block = notes.substring(start + 14, end);
    final lines = block.split('\n');
    for (final line in lines) {
      if (line.trim().startsWith('$key:')) {
        final jsonStr = line.trim().substring(key.length + 1);
        try {
          return json.decode(jsonStr) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  static String _updateNotesWithMetadata(String? notes, String key, Map<String, dynamic> jsonMap) {
    final cleanNotes = getDisplayNotes(notes);

    final dm = key == 'DM' ? jsonMap : getMetadataJson(notes, 'DM');
    final ds = key == 'DS' ? jsonMap : getMetadataJson(notes, 'DS');

    final sb = StringBuffer(cleanNotes);
    if (cleanNotes.isNotEmpty) {
      sb.write('\n\n');
    }
    sb.writeln('###METADATA###');
    if (dm != null) {
      sb.writeln('DM:${json.encode(dm)}');
    }
    if (ds != null) {
      sb.writeln('DS:${json.encode(ds)}');
    }
    sb.write('###END_METADATA###');
    return sb.toString();
  }

  static void extractAndSaveDefaultMetadata(Customer customer) {
    final dmJson = getMetadataJson(customer.notes, 'DM');
    if (dmJson != null) {
      final m = Measurement.fromJson(dmJson);
      m.isSynced = true;
      measurementsBoxInstance.put(m.id, m);
    }

    final dsJson = getMetadataJson(customer.notes, 'DS');
    if (dsJson != null) {
      final ds = StylePreference.fromJson(dsJson);
      ds.isSynced = true;
      stylePrefsBoxInstance.put(ds.id, ds);
    }
  }

  static Future<void> saveCustomerDefaultMeasurement(
      String customerId, Measurement m) async {
    m.orderId = 'customer_default_$customerId';
    m.isSynced = true;
    await measurementsBoxInstance.put(m.id, m);

    // Also update Customer notes to include this measurement
    final customer = getCustomerById(customerId);
    if (customer != null) {
      final updatedNotes = _updateNotesWithMetadata(customer.notes, 'DM', m.toJson());
      customer.notes = updatedNotes;
      customer.isSynced = false;
      await saveCustomer(customer);
    }
  }

  static StylePreference? getCustomerDefaultStyle(String customerId) {
    final key = 'customer_default_$customerId';
    try {
      return stylePrefsBoxInstance.values
          .firstWhere((s) => s.orderId == key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCustomerDefaultStyle(
      String customerId, StylePreference pref) async {
    pref.orderId = 'customer_default_$customerId';
    pref.isSynced = true;
    await stylePrefsBoxInstance.put(pref.id, pref);

    // Also update Customer notes to include this style
    final customer = getCustomerById(customerId);
    if (customer != null) {
      final updatedNotes = _updateNotesWithMetadata(customer.notes, 'DS', pref.toJson());
      customer.notes = updatedNotes;
      customer.isSynced = false;
      await saveCustomer(customer);
    }
  }

  static Future<void> saveMeasurement(Measurement measurement) async {
    await measurementsBoxInstance.put(measurement.id, measurement);
  }

  // ─── Style Preferences ──────────────────────────────────
  static Box<StylePreference> get stylePrefsBoxInstance =>
      Hive.box<StylePreference>(stylePreferencesBox);

  static StylePreference? getStyleForOrder(String orderId) {
    try {
      return stylePrefsBoxInstance.values
          .firstWhere((s) => s.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveStylePreference(StylePreference pref) async {
    await stylePrefsBoxInstance.put(pref.id, pref);
  }

  // ─── Dashboard Stats ────────────────────────────────────
  static int getTodaysOrderCount() {
    final now = DateTime.now();
    return ordersBoxInstance.values
        .where((o) =>
            !o.isDeleted &&
            o.orderDate.year == now.year &&
            o.orderDate.month == now.month &&
            o.orderDate.day == now.day)
        .length;
  }

  static int getPendingDeliveryCount() {
    return ordersBoxInstance.values
        .where((o) => !o.isDeleted && o.status != 'delivered')
        .length;
  }

  static double getPaymentsDue() {
    return ordersBoxInstance.values
        .where((o) => !o.isDeleted && !o.balancePaid)
        .fold(0.0, (sum, o) => sum + o.remainingBalance);
  }

  static List<Order> getRecentOrders([int count = 5]) {
    final orders = getActiveOrders();
    return orders.take(count).toList();
  }

  // ─── Unsynced Count ──────────────────────────────────────
  static int getUnsyncedCount() {
    int count = 0;
    count += customersBoxInstance.values.where((c) => !c.isSynced).length;
    count += ordersBoxInstance.values.where((o) => !o.isSynced).length;
    count += measurementsBoxInstance.values
        .where((m) => !m.isSynced && !m.orderId.startsWith('customer_default_'))
        .length;
    count += stylePrefsBoxInstance.values
        .where((s) => !s.isSynced && !s.orderId.startsWith('customer_default_'))
        .length;
    return count;
  }

  /// Clear all auth data on logout
  static Future<void> clearAuth() async {
    await settings.delete('auth_token');
    await settings.delete('shop_id');
    await settings.delete('shop_name');
    await settings.delete('owner_name');
    await settings.delete('contact_number');
  }

  /// Clear all local data (full reset — call on logout for multi-device safety)
  static Future<void> clearAll() async {
    await customersBoxInstance.clear();
    await ordersBoxInstance.clear();
    await measurementsBoxInstance.clear();
    await stylePrefsBoxInstance.clear();
    await settings.clear();
  }
}
