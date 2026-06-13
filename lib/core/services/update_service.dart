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
class UpdateService {
  static const String _versionUrl =
      'https://app.gfixdigital.com/version.json';
  static const String apkUrl =
      'https://app.gfixdigital.com/app-release.apk';

  /// Returns update info if newer version exists, null if up-to-date or on web.
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

      debugPrint(
          'UpdateService: remote=v$remoteVersion($remoteBuild) local=v${info.version}($localBuild)');

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

// ─── Update notification dialog ───────────────────────────────────────────────
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
                ? 'ورژن ${update.remoteVersion} دستیاب ہے\n(انسٹال: ${update.localVersion})'
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
                style: const TextStyle(fontSize: 12),
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
          onPressed: () {
            Navigator.pop(context); // close this dialog
            // Show download progress dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const _DownloadProgressDialog(),
            );
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

// ─── Download progress dialog (proper StatefulWidget — starts download once in initState) ──
class _DownloadProgressDialog extends StatefulWidget {
  const _DownloadProgressDialog();

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0;
  bool _isComplete = false;
  // Always start indeterminate — shows spinner immediately while connecting
  bool _isIndeterminate = true;
  String? _error;
  String? _apkPath;
  int _receivedBytes = 0;
  int _totalBytes = 0;

  @override
  void initState() {
    super.initState();
    // Start download exactly once, in initState — NEVER in build()
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(UpdateService.apkUrl));
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw HttpException('Status code: ${streamedResponse.statusCode}');
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      int receivedBytes = 0;

      // Switch to determinate progress if server provides Content-Length
      if (totalBytes > 0 && mounted) {
        setState(() {
          _totalBytes = totalBytes;
          _isIndeterminate = false;
        });
      }
      // If no Content-Length, stays indeterminate (already set in initState)

      Directory? dir;
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final dirs = await getExternalCacheDirectories();
          if (dirs != null && dirs.isNotEmpty) {
            dir = dirs.first;
          }
        } catch (_) {}
      }
      dir ??= await getTemporaryDirectory();
      final file = File('${dir.path}/darzi_pro_update.apk');
      final sink = file.openWrite();

      await for (final chunk in streamedResponse.stream) {
        if (!mounted) {
          sink.close();
          client.close();
          return;
        }
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && mounted) {
          setState(() {
            _receivedBytes = receivedBytes;
            _progress = receivedBytes / totalBytes;
          });
        } else if (mounted) {
          setState(() => _receivedBytes = receivedBytes);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      _apkPath = file.path;
      debugPrint('APK downloaded to: $_apkPath');

      if (mounted) {
        setState(() {
          _isComplete = true;
          _progress = 1.0;
          _isIndeterminate = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      // Close dialog and open installer
      if (mounted) {
        Navigator.pop(context);
        final result = await OpenFile.open(_apkPath!);
        debugPrint('OpenFile result: ${result.type} — ${result.message}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        setState(() => _error = 'Download failed.\nPlease try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = HiveService.language == 'ur';

    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (_isComplete ? Colors.green : kPrimary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _error != null
                  ? Icons.error_outline
                  : _isComplete
                      ? Icons.check_circle
                      : Icons.system_update,
              color: _error != null
                  ? Colors.red
                  : _isComplete
                      ? Colors.green
                      : kPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _error != null
                ? (isUrdu ? 'خرابی ہوئی' : 'Download Failed')
                : _isComplete
                    ? (isUrdu ? 'انسٹال ہو رہا ہے...' : 'Installing...')
                    : (isUrdu
                        ? 'اپڈیٹ ڈاؤن لوڈ ہو رہی ہے...'
                        : 'Downloading Update...'),
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (_error != null) ...[
            Text(
              _error!,
              style:
                  const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isUrdu ? 'بند کریں' : 'Close'),
            ),
          ] else ...[
            // Progress bar — indeterminate while connecting, determinate while downloading
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _isIndeterminate ? null : _progress,
                minHeight: 12,
                backgroundColor: kPrimary.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isComplete ? Colors.green : kPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Main progress label
            Text(
              _isComplete
                  ? (isUrdu ? 'مکمل ✓' : 'Complete ✓')
                  : _isIndeterminate && _receivedBytes == 0
                      ? (isUrdu ? 'کنیکٹ ہو رہا ہے...' : 'Connecting...')
                      : _isIndeterminate
                          ? '${(_receivedBytes / 1048576).toStringAsFixed(1)} MB'
                          : '${(_progress * 100).toInt()}%  •  ${(_receivedBytes / 1048576).toStringAsFixed(1)} / ${(_totalBytes / 1048576).toStringAsFixed(1)} MB',
              style: TextStyle(
                fontSize: 13,
                color: _isComplete ? Colors.green : kTextSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUrdu
                  ? 'ایپ بند نہ کریں'
                  : 'Please keep the app open',
              style: TextStyle(fontSize: 11, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
