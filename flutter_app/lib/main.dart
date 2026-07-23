import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/supabase_service.dart';
import 'core/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  AuthState.init();
  runApp(const FinSwitchApp());
}
