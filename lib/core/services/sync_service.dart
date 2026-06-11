import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../models/customer.dart';
import '../../models/order.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import 'hive_service.dart';
import 'supabase_service.dart';

/// Bi-directional sync service between Hive (local) and Supabase (cloud)
class SyncService {
  static bool _isSyncing = false;

  static bool get isSyncing => _isSyncing;

  /// Sync all unsynced data to Supabase
  static Future<bool> syncAll() async {
    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      await _syncCustomers();
      await _syncOrders();
      await _syncMeasurements();
      await _syncStylePreferences();

      HiveService.lastSyncTime = DateTime.now();
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('Sync error: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Pull all data from Supabase into Hive (for first login or full refresh)
  static Future<void> pullAll(String shopId) async {
    try {
      await _pullCustomers(shopId);
      await _pullOrders(shopId);
      await _pullMeasurements(shopId);
      await _pullStylePreferences(shopId);
      HiveService.lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Pull error: $e');
    }
  }

  /// Pull incremental updates since last sync
  static Future<void> pullUpdates(String shopId) async {
    try {
      final since = HiveService.lastSyncTime;
      await _pullCustomers(shopId, since: since);
      await _pullOrders(shopId, since: since);
      await _pullMeasurements(shopId, since: since);
      await _pullStylePreferences(shopId, since: since);
      HiveService.lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Pull updates error: $e');
    }
  }

  // ─── Push (Local → Cloud) ───────────────────────────────

  static Future<void> _syncCustomers() async {
    final unsynced = HiveService.customersBoxInstance.values
        .where((c) => !c.isSynced)
        .toList();

    for (final customer in unsynced) {
      try {
        await SupabaseService.upsert('customers', customer.toJson());
        customer.isSynced = true;
        await customer.save();
      } catch (e) {
        debugPrint('Sync customer ${customer.id} failed: $e');
      }
    }
  }

  static Future<void> _syncOrders() async {
    final unsynced = HiveService.ordersBoxInstance.values
        .where((o) => !o.isSynced)
        .toList();

    for (final order in unsynced) {
      try {
        await SupabaseService.upsert('orders', order.toJson());
        order.isSynced = true;
        await order.save();
      } catch (e) {
        debugPrint('Sync order ${order.id} failed: $e');
      }
    }
  }

  static Future<void> _syncMeasurements() async {
    final unsynced = HiveService.measurementsBoxInstance.values
        .where((m) => !m.isSynced && !m.orderId.startsWith('customer_default_'))
        .toList();

    for (final measurement in unsynced) {
      try {
        await SupabaseService.upsert('measurements', measurement.toJson());
        measurement.isSynced = true;
        await measurement.save();
      } catch (e) {
        debugPrint('Sync measurement ${measurement.id} failed: $e');
      }
    }
  }

  static Future<void> _syncStylePreferences() async {
    final unsynced = HiveService.stylePrefsBoxInstance.values
        .where((s) => !s.isSynced && !s.orderId.startsWith('customer_default_'))
        .toList();

    for (final pref in unsynced) {
      try {
        await SupabaseService.upsert('style_preferences', pref.toJson());
        pref.isSynced = true;
        await pref.save();
      } catch (e) {
        debugPrint('Sync style pref ${pref.id} failed: $e');
      }
    }
  }

  // ─── Pull (Cloud → Local) ──────────────────────────────

  static Future<void> _pullCustomers(String shopId,
      {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('customers', shopId,
        since: since);
    final box = HiveService.customersBoxInstance;
    for (final json in data) {
      final customer = Customer.fromJson(json);
      await box.put(customer.id, customer);
      HiveService.extractAndSaveDefaultMetadata(customer);
    }
  }

  static Future<void> _pullOrders(String shopId, {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('orders', shopId,
        since: since);
    final box = HiveService.ordersBoxInstance;
    for (final json in data) {
      final order = Order.fromJson(json);
      await box.put(order.id, order);
    }
  }

  static Future<void> _pullMeasurements(String shopId,
      {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('measurements', shopId,
        since: since);
    final box = HiveService.measurementsBoxInstance;
    for (final json in data) {
      final measurement = Measurement.fromJson(json);
      await box.put(measurement.id, measurement);
    }
  }

  static Future<void> _pullStylePreferences(String shopId,
      {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('style_preferences', shopId,
        since: since);
    final box = HiveService.stylePrefsBoxInstance;
    for (final json in data) {
      final pref = StylePreference.fromJson(json);
      await box.put(pref.id, pref);
    }
  }
}
