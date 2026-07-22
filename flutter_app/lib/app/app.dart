import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/router.dart';
import '../core/auth_state.dart';

class FinSwitchApp extends StatefulWidget {
  const FinSwitchApp({super.key});

  @override
  State<FinSwitchApp> createState() => _FinSwitchAppState();
}

class _FinSwitchAppState extends State<FinSwitchApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
    AuthState.isLoggedIn.addListener(_rebuild);
    AuthState.onboardingDone.addListener(_rebuild);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    AuthState.isLoggedIn.removeListener(_rebuild);
    AuthState.onboardingDone.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinSwitch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.value,
      routerConfig: AppRouter.router(),
    );
  }
}
