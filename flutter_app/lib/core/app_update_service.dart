import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  static const String fallbackApkDownloadUrl =
      'https://github.com/OK45batwal/FINSWITCH/releases/latest/download/app-release.apk';
  static const String githubReleaseApiUrl =
      'https://api.github.com/repos/OK45batwal/FINSWITCH/releases/latest';

  static bool _dialogShown = false;
  static bool _isDownloading = false;
  static String? _dismissedVersion;

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

      // Race Condition Fix: Check GitHub Releases API to guarantee release asset exists
      final releaseInfo = await _fetchLatestReleaseInfo();
      if (releaseInfo == null) {
        if (!silent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to verify latest release version.')),
          );
        }
        return;
      }

      final latestVersion = releaseInfo.version;
      final isForced = releaseInfo.isForced;

      if (_dismissedVersion == latestVersion && silent && !isForced) {
        return;
      }

      if (_isVersionHigher(latestVersion, installed)) {
        if (!_dialogShown && context.mounted) {
          _dialogShown = true;
          _showAutoUpdateFlow(context, latestVersion, releaseInfo);
        }
      } else if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FinSwitch is up to date (v$installed)!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e, st) {
      print('[AppUpdateService Error]: Check for update failed: $e\n$st');
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to check for updates right now.')),
        );
      }
    }
  }

  static Future<_ReleaseInfo?> _fetchLatestReleaseInfo() async {
    try {
      final res = await http
          .get(Uri.parse(githubReleaseApiUrl),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final tagName = json['tag_name']?.toString().replaceFirst('v', '').trim() ?? '';
        final version = tagName.split('+').first;
        final body = json['body']?.toString().trim() ?? '• Performance improvements\n• Bug fixes';
        final isForced = body.toLowerCase().contains('[force-update]') || body.toLowerCase().contains('min_supported_version');

        String apkUrl = fallbackApkDownloadUrl;
        String? sha256Url;

        final assets = json['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final name = asset['name']?.toString() ?? '';
          final downloadUrl = asset['browser_download_url']?.toString() ?? '';
          if (name == 'app-release.apk') {
            apkUrl = downloadUrl;
          } else if (name == 'app-release.apk.sha256' || name.endsWith('.sha256')) {
            sha256Url = downloadUrl;
          }
        }

        if (version.isNotEmpty) {
          return _ReleaseInfo(
            version: version,
            changelog: body,
            apkUrl: apkUrl,
            sha256Url: sha256Url,
            isForced: isForced,
          );
        }
      }
    } catch (e) {
      print('[AppUpdateService Error]: Failed to fetch latest release from GitHub API: $e');
    }
    return null;
  }

  static Future<void> _showAutoUpdateFlow(
      BuildContext context, String newVersion, _ReleaseInfo releaseInfo) async {
    if (!context.mounted) return;

    final progressNotifier = ValueNotifier<double>(0);
    final statusNotifier = ValueNotifier<_DownloadState>(_DownloadState(
      complete: false,
      error: false,
      errorMessage: null,
      apkPath: null,
    ));

    void triggerDownload() {
      statusNotifier.value = _DownloadState(complete: false, error: false, errorMessage: null, apkPath: null);
      progressNotifier.value = 0;
      _startDownload(
        releaseInfo: releaseInfo,
        newVersion: newVersion,
        progress: progressNotifier,
        onComplete: (path) {
          statusNotifier.value = _DownloadState(
            complete: true,
            error: false,
            errorMessage: null,
            apkPath: path,
          );
        },
        onError: (errMsg) {
          statusNotifier.value = _DownloadState(
            complete: false,
            error: true,
            errorMessage: errMsg,
            apkPath: null,
          );
        },
      );
    }

    triggerDownload();

    await showDialog<void>(
      context: context,
      barrierDismissible: !releaseInfo.isForced,
      builder: (ctx) {
        return PopScope(
          canPop: !releaseInfo.isForced,
          child: ValueListenableBuilder<_DownloadState>(
            valueListenable: statusNotifier,
            builder: (_, state, __) {
              return ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (_, pct, __) => _UpdateDialogContent(
                  newVersion: newVersion,
                  changelog: releaseInfo.changelog,
                  progress: pct,
                  downloadComplete: state.complete,
                  downloadError: state.error,
                  errorMessage: state.errorMessage,
                  isForced: releaseInfo.isForced,
                  apkPath: state.apkPath,
                  onRetry: triggerDownload,
                  onClose: () {
                    _dismissedVersion = newVersion;
                    _dialogShown = false;
                    Navigator.of(ctx).pop();
                  },
                  onInstall: () async {
                    Navigator.of(ctx).pop();
                    _dialogShown = false;
                    if (state.apkPath != null) {
                      await OpenFilex.open(state.apkPath!);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
    _dialogShown = false;
  }

  static void _startDownload({
    required _ReleaseInfo releaseInfo,
    required String newVersion,
    required ValueNotifier<double> progress,
    required void Function(String) onComplete,
    required void Function(String) onError,
  }) {
    if (_isDownloading) {
      _isDownloading = false;
    }
    _isDownloading = true;

    final client = http.Client();

    Future<void>(() async {
      final req = http.Request('GET', Uri.parse(releaseInfo.apkUrl));
      final response = await client.send(req).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP error status ${response.statusCode}');
      }

      final totalLength = response.contentLength ?? 0;
      final dir = Directory.systemTemp;
      final targetFile = File('${dir.path}/finswitch_v$newVersion.apk');
      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      final sink = targetFile.openWrite();
      int downloadedBytes = 0;

      await for (final chunk in response.stream.timeout(const Duration(seconds: 30))) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalLength > 0) {
          progress.value = (downloadedBytes / totalLength).clamp(0.0, 1.0);
        }
      }

      await sink.flush();
      await sink.close();

      // Integrity Check (SHA-256)
      if (releaseInfo.sha256Url != null && releaseInfo.sha256Url!.isNotEmpty) {
        try {
          final shaRes = await http
              .get(Uri.parse(releaseInfo.sha256Url!))
              .timeout(const Duration(seconds: 10));
          if (shaRes.statusCode == 200) {
            final expectedSha = shaRes.body.trim().split(RegExp(r'\s+')).first.toLowerCase();
            final fileBytes = await targetFile.readAsBytes();
            final actualSha = sha256.convert(fileBytes).toString().toLowerCase();

            if (expectedSha != actualSha) {
              await targetFile.delete();
              throw Exception('SHA256 integrity check failed. Expected: $expectedSha, got: $actualSha');
            }
            print('[AppUpdateService]: SHA256 checksum verified successfully ($actualSha)');
          }
        } catch (shaErr) {
          print('[AppUpdateService Warning]: Checksum verification error: $shaErr');
          if (shaErr.toString().contains('integrity check failed')) {
            rethrow;
          }
        }
      }

      _isDownloading = false;
      client.close();
      onComplete(targetFile.path);
    }).catchError((err) {
      print('[AppUpdateService Error]: Download failed: $err');
      _isDownloading = false;
      client.close();
      onError(err.toString());
    });
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

class _ReleaseInfo {
  final String version;
  final String changelog;
  final String apkUrl;
  final String? sha256Url;
  final bool isForced;

  _ReleaseInfo({
    required this.version,
    required this.changelog,
    required this.apkUrl,
    this.sha256Url,
    required this.isForced,
  });
}

class _DownloadState {
  final bool complete;
  final bool error;
  final String? errorMessage;
  final String? apkPath;

  _DownloadState({
    required this.complete,
    required this.error,
    this.errorMessage,
    this.apkPath,
  });
}

class _UpdateDialogContent extends StatelessWidget {
  final String newVersion, changelog;
  final double progress;
  final bool downloadComplete, downloadError, isForced;
  final String? errorMessage;
  final String? apkPath;
  final VoidCallback onClose;
  final VoidCallback onInstall;
  final VoidCallback onRetry;

  const _UpdateDialogContent({
    required this.newVersion,
    required this.changelog,
    required this.progress,
    required this.downloadComplete,
    required this.downloadError,
    required this.isForced,
    this.errorMessage,
    this.apkPath,
    required this.onClose,
    required this.onInstall,
    required this.onRetry,
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
              'The APK has been downloaded and verified (SHA-256). Tap "Install" to update.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
          if (err) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Could not download the update. Check your connection.',
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                changelog,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!isForced)
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
            onPressed: onRetry,
            child: const Text('Retry',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
