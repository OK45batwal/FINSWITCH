import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static const String currentVersion = '1.0.0';
  static const String apkDownloadUrl =
      'https://github.com/OK45batwal/FINSWITCH/raw/master/assets/finswitch.apk';
  static const String remotePubspecUrl =
      'https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/flutter_app/pubspec.yaml';

  static bool _dialogShown = false;

  static Future<void> checkForUpdate(BuildContext context, {bool silent = true}) async {
    try {
      final res = await http
          .get(Uri.parse(remotePubspecUrl))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return;

      final lines = res.body.split('\n');
      String? latestVersion;
      for (final line in lines) {
        if (line.trim().startsWith('version:')) {
          latestVersion = line.split(':').last.trim().split('+').first;
          break;
        }
      }

      if (latestVersion != null && _isVersionHigher(latestVersion, currentVersion)) {
        if (!_dialogShown && context.mounted) {
          _dialogShown = true;
          _showUpdateDialog(context, latestVersion);
        }
      } else if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FinSwitch is up to date!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to check for updates right now.')),
        );
      }
    }
  }

  static bool _isVersionHigher(String latest, String current) {
    try {
      final lParts = latest.split('.').map(int.parse).toList();
      final cParts = current.split('.').map(int.parse).toList();
      for (var i = 0; i < lParts.length && i < cParts.length; i++) {
        if (lParts[i] > cParts[i]) return true;
        if (lParts[i] < cParts[i]) return false;
      }
      return lParts.length > cParts.length;
    } catch (_) {
      return latest != current;
    }
  }

  static void _showUpdateDialog(BuildContext context, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.system_update_rounded, color: Color(0xFF2563EB), size: 28),
            SizedBox(width: 10),
            Text('Update Available', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version (v$newVersion) of FinSwitch is available.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Performance improvements\n• Supabase real-time sync\n• AI Copilot enhancements',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.parse(apkDownloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Update Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
