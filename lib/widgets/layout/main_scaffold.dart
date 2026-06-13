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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: kBackground,
          extendBody: !isDesktop,
          body: isDesktop
              ? Row(
                  children: [
                    _SideNavBar(
                      currentIndex: currentIndex,
                      onTabChanged: onTabChanged,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const SyncIndicator(),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SyncIndicator(),
                    Expanded(child: body),
                  ],
                ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: isDesktop
              ? null
              : _FloatingNavBar(
                  currentIndex: currentIndex,
                  onTabChanged: onTabChanged,
                ),
        );
      },
    );
  }
}

class _SideNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const _SideNavBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavData(Icons.dashboard_outlined, Icons.dashboard_rounded, AppStrings.dashboard),
      _NavData(Icons.receipt_long_outlined, Icons.receipt_long_rounded, AppStrings.orders),
      _NavData(Icons.people_outline_rounded, Icons.people_rounded, AppStrings.customers),
      _NavData(Icons.settings_outlined, Icons.settings_rounded, AppStrings.settings),
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border(right: BorderSide(color: kBorder.withOpacity(0.3), width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.content_cut, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppStrings.appName,
                  style: AppTextStyles.headlineMd.copyWith(color: kPrimary, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isActive = currentIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => onTabChanged(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isActive ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive ? [
                      BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? Colors.white : kTextSecondary,
                        size: 26,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        item.label,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: isActive ? Colors.white : kTextSecondary,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: kPrimary.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedScale(
                              scale: isActive ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: Container(
                                width: 48,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive ? kPrimary : kTextSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: AppTextStyles.labelSm.copyWith(
                            color: isActive ? kPrimary : kTextSecondary,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 10,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
