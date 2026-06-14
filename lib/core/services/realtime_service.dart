import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import '../../models/measurement.dart';
import '../../models/style_preference.dart';
import 'hive_service.dart';
import 'supabase_service.dart';

/// Enterprise Realtime Service
///
/// Uses Supabase Postgres Changes (WebSocket) to push database changes
/// directly to the device the instant they happen — no polling required.
///
/// Architecture:
///   Supabase DB change → WebSocket push → Hive update → UI notified
///
/// This eliminates ALL timestamp-based sync issues since the server pushes
/// the exact changed row, including updated status and payment fields.
class RealtimeService {
  static RealtimeChannel? _channel;
  static bool _isActive = false;

  /// Called when any remote change is written to local Hive.
  /// Wire this up to reload OrderProvider / CustomerProvider.
  static VoidCallback? onRemoteChange;

  /// Start listening to realtime changes for the given [shopId].
  /// Safe to call multiple times — idempotent.
  static void start(String shopId) {
    if (_isActive) return;
    _isActive = true;

    debugPrint('RealtimeService: subscribing for shop=$shopId');

    _channel = SupabaseService.client
        .channel('darzi_realtime_$shopId')

        // ── Orders ────────────────────────────────────────────
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'shop_id',
            value: shopId,
          ),
          callback: (payload) => _handleOrderChange(payload),
        )

        // ── Customers ─────────────────────────────────────────
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'shop_id',
            value: shopId,
          ),
          callback: (payload) => _handleCustomerChange(payload),
        )

        // ── Measurements ──────────────────────────────────────
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'measurements',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'shop_id',
            value: shopId,
          ),
          callback: (payload) => _handleMeasurementChange(payload),
        )

        // ── Style Preferences ─────────────────────────────────
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'style_preferences',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'shop_id',
            value: shopId,
          ),
          callback: (payload) => _handleStylePrefChange(payload),
        )

        // ── Shops (Subscription Status) ────────────────────────
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'shops',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: shopId,
          ),
          callback: (payload) => _handleShopChange(payload),
        )

        .subscribe((status, [error]) {
          debugPrint('RealtimeService: status=$status error=$error');
        });
  }

  /// Stop listening — call when the user logs out.
  static Future<void> stop() async {
    if (!_isActive || _channel == null) return;
    await SupabaseService.client.removeChannel(_channel!);
    _channel = null;
    _isActive = false;
    debugPrint('RealtimeService: unsubscribed');
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  static Future<void> _handleOrderChange(PostgresChangePayload payload) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) return; // DELETE event — we don't soft-delete via RT

      final incoming = Order.fromJson(json);
      incoming.isSynced = true;

      final box = HiveService.ordersBoxInstance;
      final existing = box.get(incoming.id);

      // Only skip if local has unsynced offline edits
      if (existing != null && !existing.isSynced) {
        debugPrint('RT: skipping order ${incoming.id} — local unsynced edit');
        return;
      }

      await box.put(incoming.id, incoming);
      debugPrint('RT: order ${incoming.id} status=${incoming.status} written to Hive');
      onRemoteChange?.call();
    } catch (e) {
      debugPrint('RT order handler error: $e');
    }
  }

  static Future<void> _handleCustomerChange(
      PostgresChangePayload payload) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) return;

      final incoming = Customer.fromJson(json);
      incoming.isSynced = true;

      final box = HiveService.customersBoxInstance;
      final existing = box.get(incoming.id);

      if (existing != null && !existing.isSynced) return;

      await box.put(incoming.id, incoming);
      HiveService.extractAndSaveDefaultMetadata(incoming);
      debugPrint('RT: customer ${incoming.id} written to Hive');
      onRemoteChange?.call();
    } catch (e) {
      debugPrint('RT customer handler error: $e');
    }
  }

  static Future<void> _handleMeasurementChange(
      PostgresChangePayload payload) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) return;

      final incoming = Measurement.fromJson(json);
      incoming.isSynced = true;

      final box = HiveService.measurementsBoxInstance;
      final existing = box.get(incoming.id);

      if (existing != null && !existing.isSynced) return;

      await box.put(incoming.id, incoming);
      debugPrint('RT: measurement ${incoming.id} written to Hive');
    } catch (e) {
      debugPrint('RT measurement handler error: $e');
    }
  }

  static Future<void> _handleStylePrefChange(
      PostgresChangePayload payload) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) return;

      final incoming = StylePreference.fromJson(json);
      incoming.isSynced = true;

      final box = HiveService.stylePrefsBoxInstance;
      final existing = box.get(incoming.id);

      if (existing != null && !existing.isSynced) return;

      await box.put(incoming.id, incoming);
      debugPrint('RT: style_pref ${incoming.id} written to Hive');
    } catch (e) {
      debugPrint('RT style_pref handler error: $e');
    }
  }

  static Future<void> _handleShopChange(PostgresChangePayload payload) async {
    try {
      final json = payload.newRecord;
      if (json.isEmpty) return;

      final dateStr = json['subscription_ends_at'] as String?;
      if (dateStr != null) {
        HiveService.subscriptionEndsAt = DateTime.tryParse(dateStr);
        debugPrint('RT: shop subscription updated: $dateStr');
        onRemoteChange?.call();
      }
    } catch (e) {
      debugPrint('RT shop handler error: $e');
    }
  }
}
