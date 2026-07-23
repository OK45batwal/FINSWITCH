import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  static const String apkDownloadUrl =
      'https://github.com/OK45batwal/FINSWITCH/releases/latest/download/app-arm64-v8a-release.apk';
  static const String githubReleaseApiUrl =
      'https://api.github.com/repos/OK45batwal/FINSWITCH/releases/latest';
  static const String remotePubspecUrl =
      'https://raw.githubusercontent.com/OK45batwal/FINSWITCH/master/flutter_app/pubspec.yaml';

  static bool _dialogShown = false;
  static bool _isDownloading = false;

  static Future<String?> _installedVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return null;
    }
  }

  static Future<void> checkForUpdate(BuildContext context,
      {bool silent = true}) async {
    try {
      final installed = await _installedVersion();
      if (installed == null) return;

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

      if (latestVersion != null && _isVersionHigher(latestVersion, installed)) {
        if (!_dialogShown && context.mounted) {
          _dialogShown = true;
          _showAutoUpdateFlow(context, latestVersion);
        }
      } else if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FinSwitch is up to date (v$installed)!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to check for updates right now.')),
        );
      }
    }
  }

  static Future<void> _showAutoUpdateFlow(
      BuildContext context, String newVersion) async {
    final changelog = await _fetchChangelog();
    if (!context.mounted) return;

    final progress = ValueNotifier<double>(0);
    bool downloadComplete = false;
    bool downloadError = false;
    String? apkPath;

    _startDownload(progress, (path) {
      apkPath = path;
      downloadComplete = true;
    }, () {
      downloadError = true;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, pct, __) => _UpdateDialogContent(
            newVersion: newVersion,
            changelog: changelog,
            progress: pct,
            downloadComplete: downloadComplete,
            downloadError: downloadError,
            apkPath: apkPath,
            onClose: () {
              _dialogShown = false;
              Navigator.of(ctx).pop();
            },
            onInstall: () async {
              Navigator.of(ctx).pop();
              _dialogShown = false;
              if (apkPath != null) {
                await OpenFilex.open(apkPath!);
              }
            },
          ),
        );
      },
    );
    _dialogShown = false;
  }

  static void _startDownload(
    ValueNotifier<double> progress,
    void Function(String) onComplete,
    VoidCallback onError,
  ) {
    if (_isDownloading) return;
    _isDownloading = true;

    http.Client()
        .send(http.Request('GET', Uri.parse(apkDownloadUrl)))
        .then((response) async {
      final total = response.contentLength ?? 0;
      final bytes = <int>[];
      final stream = response.stream;

      await for (final chunk in stream) {
        bytes.addAll(chunk);
        if (total > 0) {
          progress.value = bytes.length / total;
        }
      }

      final dir = Directory.systemTemp;
      final file = File('${dir.path}/finswitch.apk');
      await file.writeAsBytes(bytes);
      _isDownloading = false;
      onComplete(file.path);
    }).catchError((_) {
      _isDownloading = false;
      onError();
    });
  }

  static Future<String> _fetchChangelog() async {
    try {
      final res = await http
          .get(Uri.parse(githubReleaseApiUrl),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final body = json['body']?.toString().trim();
        if (body != null && body.isNotEmpty) return body;
      }
    } catch (_) {}
    return '• Performance improvements\n• Bug fixes';
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
}

class _UpdateDialogContent extends StatelessWidget {
  final String newVersion, changelog;
  final double progress;
  final bool downloadComplete, downloadError;
  final String? apkPath;
  final VoidCallback onClose;
  final VoidCallback onInstall;

  const _UpdateDialogContent({
    required this.newVersion,
    required this.changelog,
    required this.progress,
    required this.downloadComplete,
    required this.downloadError,
    this.apkPath,
    required this.onClose,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    final done = downloadComplete;
    final err = downloadError;

    return AlertDialog(
      backgroundColor: const Color(0xFF131D2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : err
                    ? Icons.error_outline_rounded
                    : Icons.system_update_rounded,
            color: done
                ? const Color(0xFF10B981)
                : err
                    ? Colors.redAccent
                    : const Color(0xFF38BDF8),
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            done ? 'Update Ready' : (err ? 'Update Failed' : 'Update Available'),
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'v$newVersion is available.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          if (!done && !err) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Colors.white10,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
          if (done) ...[
            const SizedBox(height: 8),
            const Text(
              'The new APK has been downloaded. Tap "Install" to update.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
          if (err) ...[
            const SizedBox(height: 8),
            const Text(
              'Could not download the update. Check your connection.',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              changelog,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: Text(
            done ? 'Later' : (err ? 'Close' : 'Cancel'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        if (done)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onInstall,
            child: const Text('Install',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        if (err)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onClose,
            child: const Text('Retry',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
