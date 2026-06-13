import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'core/constants/text_styles.dart';
import 'providers/customer_provider.dart';
import 'providers/order_provider.dart';
import 'providers/language_provider.dart';
import 'providers/sync_provider.dart';
import 'core/services/hive_service.dart';
import 'core/services/realtime_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/orders/orders_list_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/orders/new_order/new_order_screen.dart';
import 'screens/orders/collect_payment_screen.dart';
import 'screens/orders/invoice_screen.dart';
import 'screens/customers/customers_list_screen.dart';
import 'screens/customers/customer_profile_screen.dart';
import 'screens/customers/add_customer_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/shop_report_screen.dart';
import 'screens/settings/audit_logs_screen.dart';
import 'widgets/layout/main_scaffold.dart';

class DarziProApp extends StatelessWidget {
  const DarziProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isUrdu = languageProvider.isUrdu;
    final isAuth = (HiveService.authToken?.isNotEmpty ?? false);

    return MaterialApp(
      title: 'Darzi Pro',
      debugShowCheckedModeBanner: false,
      locale: isUrdu ? const Locale('ur') : const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimary,
        scaffoldBackgroundColor: kBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: kBackground,
          foregroundColor: kTextPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headlineSm,
        ),
      ),
      initialRoute: isAuth ? '/dashboard' : '/login',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final path = uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    switch (path) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const _HomeScreen(initialIndex: 0),
          settings: settings,
        );

      case '/orders':
        return MaterialPageRoute(
          builder: (_) => const _HomeScreen(initialIndex: 1),
          settings: settings,
        );

      case '/orders/new':
        return MaterialPageRoute(
          builder: (_) => const NewOrderScreen(),
          settings: settings,
        );

      case '/customers':
        return MaterialPageRoute(
          builder: (_) => const _HomeScreen(initialIndex: 2),
          settings: settings,
        );

      case '/customers/add':
        return MaterialPageRoute(
          builder: (_) => const AddCustomerScreen(),
          settings: settings,
        );

      case '/settings/report':
        return MaterialPageRoute(
          builder: (_) => const ShopReportScreen(),
          settings: settings,
        );

      case '/settings/logs':
        return MaterialPageRoute(
          builder: (_) => const AuditLogsScreen(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const _HomeScreen(initialIndex: 3),
          settings: settings,
        );

      default:
        // Dynamic routes
        if (segments.length == 2 && segments[0] == 'orders') {
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: segments[1]),
            settings: settings,
          );
        }

        if (segments.length == 3 &&
            segments[0] == 'orders' &&
            segments[2] == 'invoice') {
          return MaterialPageRoute(
            builder: (_) => InvoiceScreen(orderId: segments[1]),
            settings: settings,
          );
        }

        if (segments.length == 3 &&
            segments[0] == 'orders' &&
            segments[2] == 'payment') {
          return MaterialPageRoute(
            builder: (_) => CollectPaymentScreen(orderId: segments[1]),
            settings: settings,
          );
        }

        if (segments.length == 2 && segments[0] == 'customers') {
          return MaterialPageRoute(
            builder: (_) => CustomerProfileScreen(customerId: segments[1]),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}

/// Home screen with bottom navigation
class _HomeScreen extends StatefulWidget {
  final int initialIndex;
  const _HomeScreen({this.initialIndex = 0});

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> with WidgetsBindingObserver {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);

    // Wire up post-sync data refresh so UI updates automatically when phone
    // reconnects to internet and pulls cloud changes (no logout needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncProvider = context.read<SyncProvider>();
      syncProvider.onDataRefreshed = () {
        if (!mounted) return;
        context.read<OrderProvider>().loadOrders();
        context.read<CustomerProvider>().loadCustomers();
      };

      // Wire up realtime — any DB push updates Hive then reloads UI immediately
      final shopId = HiveService.shopId;
      if (shopId != null) {
        RealtimeService.onRemoteChange = () {
          if (!mounted) return;
          context.read<OrderProvider>().loadOrders();
          context.read<CustomerProvider>().loadCustomers();
        };
        RealtimeService.start(shopId);
      }

      // Trigger automatic full sync on startup if online
      if (syncProvider.isOnline) {
        syncProvider.syncNow(isAutomatic: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RealtimeService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-subscribe to realtime in case WebSocket was dropped in background
      final shopId = HiveService.shopId;
      if (shopId != null) {
        RealtimeService.start(shopId);
      }
      final syncProvider = context.read<SyncProvider>();
      if (syncProvider.isOnline) {
        syncProvider.syncNow(isAutomatic: true);
      }
    } else if (state == AppLifecycleState.paused) {
      // Keep realtime alive in paused (still runs), only stop on dispose
    }
  }

  final _screens = const [
    DashboardScreen(),
    OrdersListScreen(),
    CustomersListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: MainScaffold(
        currentIndex: _currentIndex,
        onTabChanged: (index) => setState(() => _currentIndex = index),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                backgroundColor: kPrimary,
                onPressed: () => Navigator.pushNamed(context, '/orders/new'),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : _currentIndex == 2
                ? FloatingActionButton(
                    backgroundColor: kPrimary,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/customers/add'),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
        body: _screens[_currentIndex],
      ),
    );
  }
}
