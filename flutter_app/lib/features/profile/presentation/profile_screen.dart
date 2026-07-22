import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

final themeNotifier = ValueNotifier(ThemeMode.dark);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
              child: const Center(child: Text('OK', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)))),
            const SizedBox(height: 12),
            Text('Omkar Batwal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('omkar.batwal@example.com', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
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
            _MenuTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Alerts and updates'),
            _MenuTile(icon: Icons.security_rounded, title: 'Security', subtitle: 'PIN, biometric & 2FA'),
            _MenuTile(icon: Icons.support_outlined, title: 'Support', subtitle: 'FAQs & contact us'),
            _MenuTile(icon: Icons.info_outline_rounded, title: 'About', subtitle: 'Version 1.0.0', trailing: Text('1.0.0', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 13))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, side: BorderSide(color: AppTheme.red.withValues(alpha: 0.3)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Sign Out'))),
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
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: muted)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppTheme.mutedOf(context), size: 20),
        contentPadding: EdgeInsets.zero, onTap: onTap,
      ),
    );
  }
}
