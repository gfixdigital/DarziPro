import 'package:flutter/material.dart';
import '../core/services/hive_service.dart';
import '../core/services/sync_service.dart';
import '../core/services/connectivity_service.dart';

/// Sync state management
class SyncProvider extends ChangeNotifier {
  final ConnectivityService _connectivity;
  bool _isSyncing = false;
  bool _lastSyncFailed = false;

  SyncProvider(this._connectivity) {
    _connectivity.onConnectivityRestored = _onConnectivityRestored;
  }

  bool get isOnline => _connectivity.isOnline;
  bool get isSyncing => _isSyncing;
  bool get lastSyncFailed => _lastSyncFailed;
  int get pendingCount => HiveService.getUnsyncedCount();
  DateTime? get lastSyncTime => HiveService.lastSyncTime;

  /// Triggered when connectivity is restored
  void _onConnectivityRestored() {
    syncNow();
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    if (_isSyncing || !_connectivity.isOnline) return;

    _isSyncing = true;
    _lastSyncFailed = false;
    notifyListeners();

    try {
      final shopId = HiveService.shopId;
      if (shopId != null) {
        // Push local changes
        final pushSuccess = await SyncService.syncAll();

        // Pull latest from cloud
        await SyncService.pullUpdates(shopId);

        _lastSyncFailed = !pushSuccess;
      }
    } catch (e) {
      _lastSyncFailed = true;
      debugPrint('Sync error: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  /// Get sync status for display
  SyncStatus get syncStatus {
    if (!_connectivity.isOnline) return SyncStatus.offline;
    if (_isSyncing) return SyncStatus.syncing;
    if (_lastSyncFailed || pendingCount > 0) return SyncStatus.pending;
    return SyncStatus.synced;
  }
}

enum SyncStatus { synced, syncing, pending, offline }
