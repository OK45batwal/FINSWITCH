import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'https://dgvtznykoyyxgwgtpbqf.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRndnR6bnlrb3l5eGd3Z3RwYnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxMTgzMTUsImV4cCI6MjA5OTY5NDMxNX0.a3dgjgZbXbCK6_DTPvjn99eb_T9HDvfPKTcNq-M49Ac';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(url: _url, publishableKey: _anonKey);
      _initialized = true;
    } catch (_) {}
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => _initialized ? client.auth.currentUser : null;

  static bool get isAuthenticated => currentUser != null;

  static Future<({String? error, AuthResponse? response})> signIn({required String email, required String password}) async {
    if (!_initialized) return (error: 'Supabase not configured', response: null);
    try {
      final r = await client.auth.signInWithPassword(email: email, password: password);
      return (error: null, response: r);
    } on AuthException catch (e) {
      return (error: e.message, response: null);
    } catch (e) {
      return (error: 'Connection error: $e', response: null);
    }
  }

  static Future<({String? error, AuthResponse? response})> signUp({required String email, required String password}) async {
    if (!_initialized) return (error: 'Supabase not configured', response: null);
    try {
      final r = await client.auth.signUp(email: email, password: password);
      return (error: null, response: r);
    } on AuthException catch (e) {
      return (error: e.message, response: null);
    } catch (e) {
      return (error: 'Connection error: $e', response: null);
    }
  }

  static Future<String?> signOut() async {
    if (!_initialized) return 'Not connected';
    try {
      await client.auth.signOut();
      return null;
    } catch (e) {
      return 'Failed to sign out: $e';
    }
  }

  static Future<String?> updateMetadata(Map<String, dynamic> data) async {
    if (!_initialized) return 'Not connected';
    try {
      await client.auth.updateUser(UserAttributes(data: data));
      return null;
    } catch (e) {
      return 'Failed to update: $e';
    }
  }
}
