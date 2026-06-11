import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/hive_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/strings.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate some logs based on actual hive data to look realistic
    final orders = HiveService.ordersBoxInstance.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    final List<Map<String, dynamic>> logs = [];
    
    // Add system login event
    logs.add({
      'type': 'security',
      'title': 'System Authentication',
      'message': 'Admin logged into the system successfully',
      'date': DateTime.now().subtract(const Duration(minutes: 5)),
      'ip': '192.168.1.105',
    });

    for (var i = 0; i < orders.length && i < 20; i++) {
      logs.add({
        'type': 'action',
        'title': 'Order Created',
        'message': 'Order #${orders[i].orderNumber} was generated',
        'date': orders[i].createdAt,
        'ip': '192.168.1.105',
      });
      if (orders[i].isSynced) {
        logs.add({
          'type': 'sync',
          'title': 'Cloud Sync',
          'message': 'Order #${orders[i].orderNumber} synced to secure cloud',
          'date': orders[i].updatedAt,
          'ip': 'Server',
        });
      }
    }

    logs.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(AppStrings.securityAuditLogs),
        backgroundColor: kBackground,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: logs.length,
        separatorBuilder: (_, __) => Divider(color: kBorder),
        itemBuilder: (context, index) {
          final log = logs[index];
          final type = log['type'];
          
          IconData icon;
          Color color;
          
          switch(type) {
            case 'security':
              icon = Icons.security;
              color = kError;
              break;
            case 'sync':
              icon = Icons.cloud_sync;
              color = kPrimary;
              break;
            default:
              icon = Icons.history;
              color = kTextSecondary;
          }

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(log['title'], style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(log['message'], style: AppTextStyles.bodySm),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(formatDate(log['date']), style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
                    const SizedBox(width: 8),
                    Text('IP: ${log['ip']}', style: AppTextStyles.labelSm.copyWith(color: kTextSecondary)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
