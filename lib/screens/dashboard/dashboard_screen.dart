import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/url_helper.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/update_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/order_card.dart';
import '../../widgets/common/custom_pull_to_refresh.dart';
import '../../providers/sync_provider.dart';

class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String? route;

  AppNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.route,
  });
}

/// Dashboard Screen — matches Stitch "Dashboard" design with Urdu localization & notifications
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
    _checkAndroidPrompt();
    _checkForUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh every time this screen becomes visible (e.g., after creating order)
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders();
        context.read<CustomerProvider>().loadCustomers();
      }
    });
  }

  void _checkAndroidPrompt() {
    if (kIsWeb && !HiveService.hasSeenAndroidPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAndroidDownloadDialog();
        }
      });
    }
  }

  void _checkForUpdate() {
    // Only check for updates on Android (web auto-deploys automatically)
    if (kIsWeb) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final update = await UpdateService.checkForUpdate();
      if (update != null && mounted) {
        // Show the reusable UpdateDialog which handles download progress
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => UpdateDialog(update: update),
        );
      }
    });
  }

  void _showAndroidDownloadDialog() {
    final isUrdu = HiveService.language == 'ur';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(
            Icons.android,
            color: Color(0xFF3DDC84),
            size: 48,
          ),
          title: Text(
            isUrdu ? 'اینڈرائیڈ ایپ دستیاب ہے!' : 'Android App Available!',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLg.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUrdu
                    ? 'بہترین تجربہ، تیز رفتار لوڈنگ اور آف لائن کام کرنے کے لیے اینڈرائیڈ ایپ ڈاؤن لوڈ کریں۔'
                    : 'Download the Android app for the best experience, offline usage, and push notifications.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                HiveService.hasSeenAndroidPrompt = true;
                Navigator.pop(ctx);
              },
              child: Text(
                isUrdu ? 'بعد میں' : 'Later',
                style: const TextStyle(color: kTextSecondary),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DDC84),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
              ),
              onPressed: () async {
                HiveService.hasSeenAndroidPrompt = true;
                Navigator.pop(ctx);
                final url = Uri.parse('${getAppUrl()}/app-release.apk');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.download, size: 18),
              label: Text(
                isUrdu ? 'ڈاؤن لوڈ کریں' : 'Download',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<AppNotification> _getNotifications(BuildContext context) {
    final list = <AppNotification>[];
    final orderProvider = context.read<OrderProvider>();
    final customerProvider = context.read<CustomerProvider>();
    final isUrdu = HiveService.language == 'ur';

    // 1. Check for urgent orders
    final urgentOrders = orderProvider.orders.where((o) => o.isUrgent && o.status != 'delivered').toList();
    for (final order in urgentOrders) {
      final customer = customerProvider.getCustomerById(order.customerId);
      final customerName = customer?.name ?? AppStrings.client;
      list.add(AppNotification(
        title: AppStrings.urgentOrder,
        message: isUrdu
            ? 'آرڈر #${order.orderNumber} ($customerName) کی ڈلیوری جلدی ہے!'
            : 'Order #${order.orderNumber} ($customerName) is urgent!',
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
        route: '/orders/${order.id}',
      ));
    }

    // 2. Check for deliveries today or tomorrow
    final now = DateTime.now();
    final todayStr = formatDateShort(now);
    final tomorrowStr = formatDateShort(now.add(const Duration(days: 1)));

    for (final order in orderProvider.orders) {
      if (order.status == 'delivered') continue;
      final deliveryDateStr = formatDateShort(order.deliveryDate);
      final customer = customerProvider.getCustomerById(order.customerId);
      final customerName = customer?.name ?? AppStrings.client;

      if (deliveryDateStr == todayStr) {
        list.add(AppNotification(
          title: AppStrings.deliveryToday,
          message: isUrdu
              ? 'آرڈر #${order.orderNumber} ($customerName) آج ڈلیور کرنا ہے!'
              : 'Order #${order.orderNumber} ($customerName) is due today!',
          icon: Icons.alarm,
          color: kPrimary,
          route: '/orders/${order.id}',
        ));
      } else if (deliveryDateStr == tomorrowStr) {
        list.add(AppNotification(
          title: AppStrings.deliveryTomorrow,
          message: isUrdu
              ? 'آرڈر #${order.orderNumber} ($customerName) کل ڈلیور کرنا ہے!'
              : 'Order #${order.orderNumber} ($customerName) is due tomorrow!',
          icon: Icons.alarm,
          color: Colors.blue,
          route: '/orders/${order.id}',
        ));
      }
    }

    // 3. Sync changes pending
    final unsynced = HiveService.getUnsyncedCount();
    if (unsynced > 0) {
      list.add(AppNotification(
        title: AppStrings.pendingSync,
        message: isUrdu
            ? '$unsynced تبدیلیاں سنک ہونا باقی ہیں۔'
            : '$unsynced changes pending sync to database.',
        icon: Icons.sync,
        color: Colors.amber,
        route: '/settings',
      ));
    }

    return list;
  }

  void _showNotificationsBottomSheet(BuildContext context, List<AppNotification> list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isUrdu = HiveService.language == 'ur';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.notifications,
                      style: AppTextStyles.headlineSm,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        AppStrings.noNewNotifications,
                        style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => Divider(color: kTextSecondary.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, color: item.color, size: 20),
                          ),
                          title: Text(
                            item.title,
                            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            item.message,
                            style: AppTextStyles.bodySm.copyWith(color: kTextSecondary),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (item.route != null) {
                              Navigator.pushNamed(context, item.route!);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final list = _getNotifications(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, size: 26, color: kTextPrimary),
          onPressed: () => _showNotificationsBottomSheet(context, list),
        ),
        if (list.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: kError,
                shape: BoxShape.circle,
                border: Border.all(color: kBackground, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '${list.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    return CustomPullToRefresh(
      onRefresh: () async {
        await context.read<SyncProvider>().syncNow();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getGreeting()},',
                    style: AppTextStyles.bodySm,
                  ),
                  Text(
                    auth.ownerName,
                    style: AppTextStyles.headlineSm,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNotificationBell(context),
                  const SizedBox(width: 8),
                  // Profile avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimary.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getInitials(auth.ownerName),
                        style: AppTextStyles.labelLg.copyWith(
                          color: kPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stat cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: AppStrings.todaysOrders,
                  value: '${orders.todaysOrders}',
                  icon: Icons.receipt_long_outlined,
                  color: kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: AppStrings.pendingDelivery,
                  value: '${orders.pendingDelivery}',
                  icon: Icons.local_shipping_outlined,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payments Due card
          _PaymentsDueCard(amount: orders.paymentsDue),
          const SizedBox(height: 24),

          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: AppStrings.newOrder,
                  icon: Icons.add,
                  onPressed: () => Navigator.pushNamed(context, '/orders/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: AppStrings.addCustomer,
                  icon: Icons.person_add_outlined,
                  isOutlined: true,
                  onPressed: () => Navigator.pushNamed(context, '/customers/add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Recent Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.recentOrders, style: AppTextStyles.headlineSm),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/orders'),
                child: Text(
                  AppStrings.viewAll,
                  style: AppTextStyles.labelLg.copyWith(color: kPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent orders list
          if (orders.recentOrders.isEmpty)
            _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noOrdersYet,
              subtitle: AppStrings.createFirstOrder,
            )
          else
            ...orders.recentOrders.map((order) {
              final customer = context.read<CustomerProvider>().getCustomerById(order.customerId);
              return OrderCard(
                order: order,
                customer: customer,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/orders/${order.id}',
                ),
              );
            }),

          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kPrimary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSm,
          ),
        ],
      ),
    );
  }
}

/// Payments due card
class _PaymentsDueCard extends StatelessWidget {
  final double amount;

  const _PaymentsDueCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.paymentsDue,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(amount),
                  style: AppTextStyles.headlineSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kPrimary.withOpacity(0.5), size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
