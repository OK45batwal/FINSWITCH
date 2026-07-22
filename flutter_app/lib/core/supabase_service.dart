import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _defaultUrl = 'https://placeholder.supabase.co';
  static const String _defaultAnonKey = 'placeholder';

  static bool _initialized = false;

  static Future<void> initialize({String? url, String? anonKey}) async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: url ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: _defaultUrl),
        anonKey: anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: _defaultAnonKey),
      );
      _initialized = true;
    } catch (_) {
      // Fallback if offline / placeholder
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => _initialized ? client.auth.currentUser : null;

  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse?> signIn({required String email, required String password}) async {
    if (!_initialized) return null;
    try {
      return await client.auth.signInWithPassword(email: email, password: password);
    } catch (_) {
      return null;
    }
  }

  static Future<AuthResponse?> signUp({required String email, required String password}) async {
    if (!_initialized) return null;
    try {
      return await client.auth.signUp(email: email, password: password);
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    if (_initialized) {
      await client.auth.signOut();
    }
  }
}
