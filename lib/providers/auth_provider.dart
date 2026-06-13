import 'package:flutter/material.dart';
import '../core/services/hive_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/sync_service.dart';
import '../core/services/realtime_service.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  String get shopId => HiveService.shopId ?? '';
  String get ownerName => HiveService.ownerName ?? 'Darzi';
  String get shopName => HiveService.shopName ?? 'Darzi Pro';

  bool get isExpired {
    final endsAt = HiveService.subscriptionEndsAt;
    // If no date is set, we assume they are NOT expired (safe fallback)
    if (endsAt == null) return false;
    return DateTime.now().isAfter(endsAt);
  }

  /// Check if user is already authenticated (app restart)
  Future<void> checkAuth() async {
    final token = HiveService.authToken;
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      notifyListeners();
      
      // Perform a background network check for plan validity
      _syncSubscriptionStatus();
    }
  }

  Future<void> _syncSubscriptionStatus() async {
    try {
      final shopId = HiveService.shopId;
      if (shopId != null && shopId.isNotEmpty) {
        final shopData = await SupabaseService.fetchShop(shopId);
        if (shopData != null) {
          final dateStr = shopData['subscription_ends_at'] as String?;
          if (dateStr != null) {
            final oldStatus = isExpired;
            HiveService.subscriptionEndsAt = DateTime.tryParse(dateStr);
            if (isExpired != oldStatus) {
              notifyListeners(); // Force a UI update if their plan just expired
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Login with phone and password
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normalize phone to E.164 format (+923XXXXXXXXX)
      String formattedPhone = phone.trim();
      // Remove any spaces or dashes
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[\s\-]'), '');
      // Strip leading + sign temporarily
      if (formattedPhone.startsWith('+')) {
        formattedPhone = formattedPhone.substring(1);
      }
      // Strip leading 92 (country code without +)
      if (formattedPhone.startsWith('92') && formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(2);
      }
      // Strip leading 0
      if (formattedPhone.startsWith('0')) {
        formattedPhone = formattedPhone.substring(1);
      }
      // Now formattedPhone should be the 10-digit local number (3XXXXXXXXX)
      formattedPhone = '+92$formattedPhone';

      final response = await SupabaseService.signIn(
        phone: formattedPhone,
        password: password,
      );

      if (response.session != null) {
        // Store auth data
        HiveService.authToken = response.session!.accessToken;

        // Get shop info from user metadata
        final shopId = response.user?.userMetadata?['shop_id'] as String?;
        if (shopId != null) {
          HiveService.shopId = shopId;

          // Pull shop details
          final shopData = await SupabaseService.fetchShop(shopId);
          if (shopData != null) {
            HiveService.shopName = shopData['name'] as String?;
            HiveService.ownerName = shopData['owner_name'] as String?;
            
            final dateStr = shopData['subscription_ends_at'] as String?;
            if (dateStr != null) {
              HiveService.subscriptionEndsAt = DateTime.tryParse(dateStr);
            }

            // Normalize phone: strip +92/92 prefix before storing
            final rawPhone = (shopData['phone'] as String? ?? '');
            HiveService.contactNumber = rawPhone
                .replaceAll('+92', '')
                .replaceAll(RegExp(r'^92'), '')
                .trim();
          }

          // CRITICAL FIX: Clear stale local data before pulling from cloud.
          await HiveService.ordersBoxInstance.clear();
          await HiveService.customersBoxInstance.clear();
          await HiveService.measurementsBoxInstance.clear();
          await HiveService.stylePrefsBoxInstance.clear();

          // Pull fresh data from cloud
          await SyncService.pullAll(shopId);

          // Start realtime subscription so any future web changes
          // are pushed to device instantly without needing a manual sync
          RealtimeService.start(shopId);
        }

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Stop realtime WebSocket before signing out
      await RealtimeService.stop();
      await SupabaseService.signOut();
    } catch (_) {}
    await HiveService.clearAuth();
    _isAuthenticated = false;
    notifyListeners();
  }
}
