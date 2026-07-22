import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/router.dart';

class FinSwitchApp extends StatelessWidget {
  const FinSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinSwitch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
