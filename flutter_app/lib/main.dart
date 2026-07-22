import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const FinSwitchApp());
}

