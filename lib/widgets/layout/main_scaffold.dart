import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../widgets/common/sync_indicator.dart';

/// Main scaffold with premium pill-style bottom navigation
class MainScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final ValueChanged<int> onTabChanged;
  final Widget? floatingActionButton;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.onTabChanged,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Column(
        children: [
          const SyncIndicator(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: currentIndex,
        onTabChanged: onTabChanged,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavData(Icons.dashboard_outlined, Icons.dashboard_rounded,
          AppStrings.dashboard),
      _NavData(Icons.receipt_long_outlined, Icons.receipt_long_rounded,
          AppStrings.orders),
      _NavData(Icons.people_outline_rounded, Icons.people_rounded,
          AppStrings.customers),
      _NavData(Icons.settings_outlined, Icons.settings_rounded,
          AppStrings.settings),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: kPrimary.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: kPrimary.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kPrimary, kPrimaryDark],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? Colors.white : kTextSecondary,
                          size: 22,
                        ),
                        // Show label text only on active tab
                        if (isActive) ...[
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              item.label,
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavData(this.icon, this.activeIcon, this.label);
}
