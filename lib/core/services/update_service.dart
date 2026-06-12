import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/services/hive_service.dart';

/// Checks if a newer version of the Android app is available.
/// Shows a download dialog with real-time progress bar.
class UpdateService {
  static const String _versionUrl =
      'https://app.gfixdigital.com/version.json';
  static const String _apkUrl =
      'https://app.gfixdigital.com/app-release.apk';

  /// Checks for update. Returns null if up-to-date or on web.
  static Future<UpdateInfo?> checkForUpdate() async {
    if (kIsWeb) return null;

    try {
      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final remoteVersion = data['version'] as String? ?? '0.0.0';
      final remoteBuild = data['build'] as int? ?? 0;
      final releaseNotes = data['releaseNotes'] as String? ?? '';

      final info = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(info.buildNumber) ?? 0;

      debugPrint('UpdateService: remote=$remoteBuild local=$localBuild');

      // Only show if server has a strictly higher build number
      if (remoteBuild > localBuild) {
        return UpdateInfo(
          remoteVersion: remoteVersion,
          remoteBuild: remoteBuild,
          localVersion: info.version,
          localBuild: localBuild,
          releaseNotes: releaseNotes,
        );
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }

    return null;
  }

  /// Shows an in-app download progress dialog and installs the APK.
  static Future<void> downloadAndInstall(BuildContext context) async {
    if (kIsWeb) return;
    final isUrdu = HiveService.language == 'ur';

    double progress = 0;
    bool isComplete = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            // Start download on first build
            if (progress == 0 && !isComplete && error == null) {
              _downloadApk(
                onProgress: (p) {
                  if (ctx.mounted) setState(() => progress = p);
                },
                onComplete: (path) async {
                  if (ctx.mounted) setState(() => isComplete = true);
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (ctx.mounted) Navigator.pop(ctx);
                  await OpenFile.open(path);
                },
                onError: (e) {
                  if (ctx.mounted) setState(() => error = e);
                },
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isComplete
                          ? Icons.check_circle
                          : Icons.system_update,
                      color: isComplete ? Colors.green : kPrimary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    error != null
                        ? (isUrdu ? 'خرابی ہوئی' : 'Download Failed')
                        : isComplete
                            ? (isUrdu ? 'ڈاؤن لوڈ مکمل!' : 'Download Complete!')
                            : (isUrdu ? 'اپڈیٹ ڈاؤن لوڈ ہو رہی ہے...' : 'Downloading Update...'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  if (error != null) ...[
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(isUrdu ? 'بند کریں' : 'Close'),
                    ),
                  ] else ...[
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: isComplete ? 1.0 : progress,
                        minHeight: 10,
                        backgroundColor: kPrimary.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? Colors.green : kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Percentage text
                    Text(
                      isComplete
                          ? (isUrdu ? 'انسٹال ہو رہا ہے...' : 'Installing...')
                          : '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _downloadApk({
    required void Function(double) onProgress,
    required void Function(String) onComplete,
    required void Function(String) onError,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(_apkUrl));
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/darzi_pro_update.apk');
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      onComplete(file.path);
    } catch (e) {
      onError('Download failed: ${e.toString().substring(0, 60)}');
    }
  }
}

class UpdateInfo {
  final String remoteVersion;
  final int remoteBuild;
  final String localVersion;
  final int localBuild;
  final String releaseNotes;

  const UpdateInfo({
    required this.remoteVersion,
    required this.remoteBuild,
    required this.localVersion,
    required this.localBuild,
    required this.releaseNotes,
  });
}

// ─── Reusable update dialog widget ───────────────────────────────────────────
class UpdateDialog extends StatelessWidget {
  final UpdateInfo update;
  const UpdateDialog({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final isUrdu = HiveService.language == 'ur';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.system_update, color: kPrimary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isUrdu ? 'نئی اپڈیٹ دستیاب!' : 'New Update Available!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isUrdu
                ? 'ورژن ${update.remoteVersion} دستیاب ہے\n(آپ کا ورژن: ${update.localVersion})'
                : 'Version ${update.remoteVersion} is available\n(Installed: ${update.localVersion})',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (update.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                update.releaseNotes,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            isUrdu ? 'بعد میں' : 'Later',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () async {
            Navigator.pop(context); // close this dialog
            // Open download progress dialog
            if (context.mounted) {
              await UpdateService.downloadAndInstall(context);
            }
          },
          icon: const Icon(Icons.download, size: 18),
          label: Text(
            isUrdu ? 'ابھی اپڈیٹ کریں' : 'Update Now',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
