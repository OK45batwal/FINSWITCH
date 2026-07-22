import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/router.dart';
import '../features/profile/presentation/profile_screen.dart';

class FinSwitchApp extends StatelessWidget {
  const FinSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _AppWithTheme();
  }
}

class _AppWithTheme extends StatefulWidget {
  @override
  State<_AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<_AppWithTheme> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp.router(
        title: 'FinSwitch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        routerConfig: AppRouter.router(),
      ),
    );
  }
}
