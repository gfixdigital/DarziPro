import 'package:flutter/material.dart';
import '../core/services/hive_service.dart';
import '../core/services/sync_service.dart';
import '../core/services/connectivity_service.dart';

/// Sync state management
class SyncProvider extends ChangeNotifier {
  final ConnectivityService _connectivity;
  bool _isSyncing = false;
  bool _lastSyncFailed = false;
  DateTime? _lastAutoSyncTime;

  /// Called after a successful pull so the app can reload data into providers
  VoidCallback? onDataRefreshed;

  SyncProvider(this._connectivity) {
    _connectivity.onConnectivityRestored = _onConnectivityRestored;
  }

  bool get isOnline => _connectivity.isOnline;
  bool get isSyncing => _isSyncing;
  bool get lastSyncFailed => _lastSyncFailed;
  int get pendingCount => HiveService.getUnsyncedCount();
  DateTime? get lastSyncTime => HiveService.lastSyncTime;

  /// Triggered automatically when connectivity is restored
  void _onConnectivityRestored() {
    syncNow(isAutomatic: true);
  }

  /// Manually trigger sync (push local → cloud, then pull cloud → local)
  Future<void> syncNow({bool isAutomatic = false}) async {
    if (_isSyncing || !_connectivity.isOnline) return;

    final now = DateTime.now();
    if (isAutomatic && _lastAutoSyncTime != null) {
      final difference = now.difference(_lastAutoSyncTime!);
      if (difference.inSeconds < 30) {
        debugPrint('SyncProvider: Throttling automatic sync. Last sync was ${difference.inSeconds}s ago.');
        return;
      }
    }

    _isSyncing = true;
    _lastSyncFailed = false;
    notifyListeners();

    try {
      final shopId = HiveService.shopId;
      if (shopId != null) {
        // Push local changes first
        final pushSuccess = await SyncService.syncAll();

        // Pull latest from cloud (incremental — only changes since lastSyncTime)
        await SyncService.pullUpdates(shopId);

        _lastSyncFailed = !pushSuccess;
        _lastAutoSyncTime = DateTime.now();

        // Notify the app to reload data from Hive into memory (refreshes UI)
        onDataRefreshed?.call();
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
