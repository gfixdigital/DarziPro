import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

/// Supabase cloud service wrapper
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  /// Sign in with phone and password
  static Future<AuthResponse> signIn({
    required String phone,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Get shop ID from user metadata
  static String? get shopId {
    final metadata = currentUser?.userMetadata;
    return metadata?['shop_id'] as String?;
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Upsert data to a table
  static Future<void> upsert(String table, Map<String, dynamic> data) async {
    await client.from(table).upsert(data);
  }

  /// Fetch all data for a shop from a table
  static Future<List<Map<String, dynamic>>> fetchAll(
    String table,
    String shopId, {
    DateTime? since,
  }) async {
    var query = client.from(table).select().eq('shop_id', shopId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch shop details
  static Future<Map<String, dynamic>?> fetchShop(String shopId) async {
    final response =
        await client.from('shops').select().eq('id', shopId).maybeSingle();
    return response;
  }

  /// Update shop details
  static Future<void> updateShop(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    await client.from('shops').update(data).eq('id', shopId);
  }
}
