import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/sync_provider.dart';

/// Persistent sync indicator banner at top of main screens
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, sync, _) {
        switch (sync.syncStatus) {
          case SyncStatus.synced:
            return const SizedBox.shrink();

          case SyncStatus.syncing:
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: kPrimary.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.syncing,
                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                  ),
                ],
              ),
            );

          case SyncStatus.pending:
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.amber.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sync_problem, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.syncPending,
                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                  ),
                ],
              ),
            );

          case SyncStatus.offline:
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.grey.shade600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppStrings.offlineSync,
                      style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
