import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactController = TextEditingController();

  bool _newOrderAlerts = true;
  bool _measurementReminders = true;
  bool _dailySummary = false;

  @override
  void initState() {
    super.initState();
    _shopNameController.text = HiveService.shopName ?? '';
    _ownerNameController.text = HiveService.ownerName ?? '';
    // Strip any existing +92/92 prefix to avoid double prefix display
    final rawPhone = HiveService.contactNumber ?? '';
    _contactController.text = rawPhone
        .replaceAll('+92', '')
        .replaceAll(RegExp(r'^92'), '')
        .trim();

    _newOrderAlerts = HiveService.newOrderAlerts;
    _measurementReminders = HiveService.measurementReminders;
    _dailySummary = HiveService.dailySummary;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final shopId = HiveService.shopId;
    if (shopId == null) return;

    // Save locally first (instant feedback)
    HiveService.shopName = _shopNameController.text.trim();
    HiveService.ownerName = _ownerNameController.text.trim();
    // Normalize: strip any +92/92 prefix, store only the local digits
    final rawPhone = _contactController.text.trim();
    final cleanPhone = rawPhone
        .replaceAll('+92', '')
        .replaceAll(RegExp(r'^92'), '')
        .trim();
    HiveService.contactNumber = cleanPhone;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(HiveService.language == 'ur' ? 'محفوظ ہو رہا ہے...' : 'Saving...'),
        duration: const Duration(seconds: 1),
        backgroundColor: kPrimary,
      ),
    );

    try {
      await SupabaseService.updateShop(shopId, {
        'name': _shopNameController.text.trim(),
        'owner_name': _ownerNameController.text.trim(),
        // Send full E.164 format to Supabase (+92 + local digits)
        'phone': '+92$cleanPhone',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(HiveService.language == 'ur' ? 'پروفائل محفوظ ہو گئی ✓' : 'Profile saved ✓'),
            backgroundColor: kPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              HiveService.language == 'ur'
                  ? 'مقامی طور پر محفوظ ہو گیا۔ کلاؤڈ سنک ناکام ہوا: $e'
                  : 'Saved locally. Cloud sync failed: $e',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.logOut),
        content: Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            child: Text(AppStrings.logOut, style: const TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(AppStrings.settings, style: AppTextStyles.headlineMd),
          const SizedBox(height: 4),
          Text(AppStrings.settingsSubtitle, style: AppTextStyles.bodySm),
          const SizedBox(height: 20),

          // Profile Information
          _buildCard(AppStrings.profileInfo, [
            AppInput(label: AppStrings.shopName, controller: _shopNameController),
            const SizedBox(height: 12),
            AppInput(label: AppStrings.ownerName, controller: _ownerNameController),
            const SizedBox(height: 12),
            AppInput(
              label: AppStrings.contactNumber,
              controller: _contactController,
              keyboardType: TextInputType.phone,
              prefix: Text('+92', style: AppTextStyles.bodyMd.copyWith(color: kTextSecondary)),
            ),
            const SizedBox(height: 16),
            AppButton(text: AppStrings.saveChanges, onPressed: _saveProfile),
          ]),
          const SizedBox(height: 16),

          // Preferences
          _buildCard(AppStrings.preferences, [
            _buildLanguageDropdownRow(context),
            const SizedBox(height: 12),
            _buildDropdownRow(AppStrings.currencyFormat, 'PKR (Rs.)'),
          ]),
          const SizedBox(height: 16),

          // Notifications
          _buildCard(AppStrings.notifications, [
            _buildToggle(AppStrings.newOrderAlerts, _newOrderAlerts, (v) {
              setState(() => _newOrderAlerts = v);
              HiveService.newOrderAlerts = v;
            }),
            _buildToggle(AppStrings.measurementReminders, _measurementReminders, (v) {
              setState(() => _measurementReminders = v);
              HiveService.measurementReminders = v;
            }),
            _buildToggle(AppStrings.dailySummary, _dailySummary, (v) {
              setState(() => _dailySummary = v);
              HiveService.dailySummary = v;
            }),
          ]),
          const SizedBox(height: 16),

          // Sync Status
          _buildCard(AppStrings.syncStatus, [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sync.lastSyncTime != null
                            ? '${AppStrings.lastSync}: ${formatDate(sync.lastSyncTime!)}'
                            : AppStrings.neverSynced,
                        style: AppTextStyles.bodySm,
                      ),
                      if (sync.pendingCount > 0)
                        Text(
                          '${sync.pendingCount} ${AppStrings.changesPending}',
                          style: AppTextStyles.labelSm.copyWith(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: AppStrings.syncNow,
                  width: 120,
                  isLoading: sync.isSyncing,
                  onPressed: () => sync.syncNow(),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),

          // Download Android App (Web only)
          if (kIsWeb) ...[
            _buildDownloadAndroidCard(),
            const SizedBox(height: 16),
          ],

          // Reports & Logs
          _buildCard(AppStrings.reportsLogs, [
            AppButton(
              text: AppStrings.generateShopReport,
              icon: Icons.analytics_outlined,
              isOutlined: true,
              onPressed: () => Navigator.pushNamed(context, '/settings/report'),
            ),
            const SizedBox(height: 12),
            AppButton(
              text: AppStrings.viewSecurityLogs,
              icon: Icons.security_outlined,
              isOutlined: true,
              onPressed: () => Navigator.pushNamed(context, '/settings/logs'),
            ),
          ]),
          const SizedBox(height: 24),

          // Logout button
          AppButton(
            text: AppStrings.logOut,
            isOutlined: true,
            isDanger: true,
            icon: Icons.logout,
            onPressed: _handleLogout,
          ),
          const SizedBox(height: 16),

          // Version
          Center(
            child: Column(
              children: [
                Text(
                  'Darzi Pro ${AppStrings.appVersion}',
                  style: AppTextStyles.labelSm.copyWith(color: kTextSecondary.withOpacity(0.5)),
                ),
                const SizedBox(height: 4),
                Text(
                  '© GFix Digital. All rights reserved.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: kPrimary.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLg),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageDropdownRow(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isUrdu = languageProvider.isUrdu;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppStrings.appLanguage, style: AppTextStyles.bodyMd),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isUrdu ? 'ur' : 'en',
              icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
              style: AppTextStyles.bodySm.copyWith(
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ur', child: Text('اردو')),
              ],
              onChanged: (val) {
                if (val != null) {
                  languageProvider.setLanguage(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDropdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: AppTextStyles.bodySm),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Switch(value: value, activeColor: kPrimary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDownloadAndroidCard() {
    final isUrdu = HiveService.language == 'ur';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3DDC84), Color(0xFF007A33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3DDC84).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.android,
              color: Color(0xFF3DDC84),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? 'اینڈرائیڈ ایپ ڈاؤن لوڈ کریں' : 'Download Android App',
                  style: AppTextStyles.labelLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUrdu
                      ? 'موبائل پر بہترین کارکردگی اور آف لائن کام کرنے کے لیے!'
                      : 'Get the mobile app for offline use and real-time alerts!',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF007A33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
            ),
            onPressed: () async {
              final url = Uri.parse('https://darzi-pro-pink.vercel.app/app-release.apk');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}

