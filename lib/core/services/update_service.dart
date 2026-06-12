import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Checks if a newer version of the Android app is available on the server.
/// Only runs on Android (not on web).
class UpdateService {
  static const String _versionUrl = 'https://app.gfixdigital.com/version.json';

  /// Returns update info if a newer version is available, null otherwise.
  static Future<UpdateInfo?> checkForUpdate() async {
    // Only check on Android — web updates itself automatically
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

      // Get installed app version
      final info = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(info.buildNumber) ?? 0;

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
