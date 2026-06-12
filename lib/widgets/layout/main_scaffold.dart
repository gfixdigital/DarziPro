import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/strings.dart';
import '../../widgets/common/sync_indicator.dart';

/// Main scaffold with floating pill-style bottom navigation
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
      extendBody: true, // body extends behind the floating nav
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
      _NavData(Icons.dashboard_outlined, Icons.dashboard, AppStrings.dashboard),
      _NavData(Icons.receipt_long_outlined, Icons.receipt_long, AppStrings.orders),
      _NavData(Icons.people_outline, Icons.people, AppStrings.customers),
      _NavData(Icons.settings_outlined, Icons.settings, AppStrings.settings),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              // Center items get the elevated pill treatment
              final isCenterActive = isActive && (index == 1 || index == 2);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: isActive ? 48 : 40,
                        height: isActive ? 48 : 40,
                        decoration: BoxDecoration(
                          color: isActive ? kPrimary : Colors.transparent,
                          shape: BoxShape.circle,
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
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? Colors.white : kTextSecondary,
                          size: isActive ? 22 : 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 5 : 0,
                        height: isActive ? 5 : 0,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
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
