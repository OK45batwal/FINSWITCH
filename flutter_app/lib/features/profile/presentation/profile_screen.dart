import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/config/theme.dart';
import '../../../core/auth_state.dart';
import '../../../core/app_update_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _busy = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    final err = await AuthState.logout();
    if (mounted) {
      setState(() => _busy = false);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
      context.go('/create-account');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = AuthState.userName.value ?? 'User';
    final email = AuthState.userEmail.value ?? 'user@finswitch.app';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 20),
            Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
              child: Center(child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)))),
            const SizedBox(height: 12),
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: themeNotifier,
              builder: (_, mode, __) => _MenuTile(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                title: isDark ? 'Light Mode' : 'Dark Mode',
                subtitle: 'Switch theme',
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
            const _MenuTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Alerts and updates'),
            const _MenuTile(icon: Icons.security_rounded, title: 'Security', subtitle: 'PIN, biometric & 2FA'),
            _MenuTile(icon: Icons.system_update_rounded, title: 'Check for Updates', subtitle: 'v$_appVersion installed', onTap: () => AppUpdateService.checkForUpdate(context, silent: false)),
            const _MenuTile(icon: Icons.support_outlined, title: 'Support', subtitle: 'FAQs & contact us'),
            _MenuTile(icon: Icons.info_outline_rounded, title: 'About', subtitle: 'Version $_appVersion', trailing: Text(_appVersion, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _signOut,
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, side: BorderSide(color: AppTheme.red.withValues(alpha: 0.3)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.red)) : const Text('Sign Out'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _MenuTile({required this.icon, required this.title, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.emeraldGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.emeraldGreen, size: 22)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: muted)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
        contentPadding: EdgeInsets.zero, onTap: onTap,
      ),
    );
  }
}
