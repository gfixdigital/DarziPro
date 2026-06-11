import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/connectivity_service.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/order_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await HiveService.init();

  // Reset language to English (safe default — Urdu RTL was causing layout issues)
  HiveService.language = 'en';

  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Supabase init failed (offline mode): $e');
  }

  // Initialize connectivity
  final connectivity = ConnectivityService();
  await connectivity.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()..loadCustomers()),
        ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()),
        ChangeNotifierProvider.value(value: connectivity),
        ChangeNotifierProvider(
          create: (context) => SyncProvider(connectivity),
        ),
      ],
      child: const DarziProApp(),
    ),
  );
}
