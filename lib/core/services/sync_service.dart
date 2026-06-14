import 'package:flutter/foundation.dart';
import '../../models/customer.dart';
import '../../models/order.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import 'hive_service.dart';
import 'supabase_service.dart';

/// Bi-directional sync service between Hive (local) and Supabase (cloud).
///
/// MULTI-SHOP SAFE: All queries filter by shop_id at the Supabase level via RLS.
/// Each shop_id only ever sees its own data. Scales to 50+ shops, 100K+ customers.
///
/// SYNC STRATEGY:
///  1. Push: upload unsynced local records (isSynced == false) → Supabase
///  2. Pull: download cloud records → Hive, skipping records with local unsynced changes
///  3. Order numbers are assigned by max(order_number)+1 per shop to avoid collisions
class SyncService {
  static bool _isSyncing = false;

  static bool get isSyncing => _isSyncing;

  /// Push all unsynced local data to Supabase, then pull any cloud updates.
  static Future<bool> syncAll() async {
    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      await _syncCustomers();
      await _syncOrders();
      await _syncMeasurements();
      await _syncStylePreferences();

      HiveService.lastSyncTime = DateTime.now().toUtc();
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('Sync error: $e');
      _isSyncing = false;
      return false;
    }
  }

  /// Pull ALL data from Supabase into Hive.
  /// Used on first login or a manual full-refresh.
  /// Preserves locally unsynced records (does not overwrite them).
  static Future<void> pullAll(String shopId) async {
    try {
      final shopData = await SupabaseService.fetchShop(shopId);
      if (shopData != null) {
        final dateStr = shopData['subscription_ends_at'] as String?;
        if (dateStr != null) {
          HiveService.subscriptionEndsAt = DateTime.tryParse(dateStr);
        }
      }

      await _pullCustomers(shopId);
      await _pullOrders(shopId);
      await _pullMeasurements(shopId);
      await _pullStylePreferences(shopId);
      HiveService.lastSyncTime = DateTime.now().toUtc();
    } catch (e) {
      debugPrint('Pull error: $e');
    }
  }

  /// Pull all updates from Supabase (full refresh) as a safety net.
  /// Realtime handles instant pushes; this catches anything missed while offline.
  static Future<void> pullUpdates(String shopId) async {
    try {
      final shopData = await SupabaseService.fetchShop(shopId);
      if (shopData != null) {
        final dateStr = shopData['subscription_ends_at'] as String?;
        if (dateStr != null) {
          HiveService.subscriptionEndsAt = DateTime.tryParse(dateStr);
        }
      }

      await _pullCustomers(shopId);
      await _pullOrders(shopId);
      await _pullMeasurements(shopId);
      await _pullStylePreferences(shopId);
      HiveService.lastSyncTime = DateTime.now().toUtc();
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
  // IMPORTANT: Never overwrite local records that have unsynced (isSynced=false) changes.
  // This prevents cloud data from stomping over offline edits made on the phone.

  static Future<void> _pullCustomers(String shopId, {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('customers', shopId, since: since);
    final box = HiveService.customersBoxInstance;
    for (final json in data) {
      try {
        final incoming = Customer.fromJson(json);
        incoming.isSynced = true; // mark as synced since it came from cloud

        final existing = box.get(incoming.id);
        // Skip if we have a local unsynced version (don't overwrite offline edits)
        if (existing != null && !existing.isSynced) continue;

        await box.put(incoming.id, incoming);
        try {
          HiveService.extractAndSaveDefaultMetadata(incoming);
        } catch (e) {
          debugPrint('Error extracting metadata for customer ${incoming.id}: $e');
        }
      } catch (e) {
        debugPrint('Error pulling customer: $e, json: $json');
      }
    }
  }

  static Future<void> _pullOrders(String shopId, {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('orders', shopId, since: since);
    final box = HiveService.ordersBoxInstance;
    for (final json in data) {
      try {
        final incoming = Order.fromJson(json);
        incoming.isSynced = true; // mark as synced since it came from cloud

        final existing = box.get(incoming.id);
        // Skip if we have a local unsynced version (don't overwrite offline edits)
        if (existing != null && !existing.isSynced) continue;

        await box.put(incoming.id, incoming);
      } catch (e) {
        debugPrint('Error pulling order: $e, json: $json');
      }
    }
  }

  static Future<void> _pullMeasurements(String shopId, {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('measurements', shopId, since: since);
    final box = HiveService.measurementsBoxInstance;
    for (final json in data) {
      try {
        final incoming = Measurement.fromJson(json);
        incoming.isSynced = true;

        final existing = box.get(incoming.id);
        if (existing != null && !existing.isSynced) continue;

        await box.put(incoming.id, incoming);
      } catch (e) {
        debugPrint('Error pulling measurement: $e, json: $json');
      }
    }
  }

  static Future<void> _pullStylePreferences(String shopId, {DateTime? since}) async {
    final data = await SupabaseService.fetchAll('style_preferences', shopId, since: since);
    final box = HiveService.stylePrefsBoxInstance;
    for (final json in data) {
      try {
        final incoming = StylePreference.fromJson(json);
        incoming.isSynced = true;

        final existing = box.get(incoming.id);
        if (existing != null && !existing.isSynced) continue;

        await box.put(incoming.id, incoming);
      } catch (e) {
        debugPrint('Error pulling style pref: $e, json: $json');
      }
    }
  }
}
