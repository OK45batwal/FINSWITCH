import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthState {
  static final isLoggedIn = ValueNotifier<bool>(false);
  static final token = ValueNotifier<String?>(null);
  static final userEmail = ValueNotifier<String?>(null);
  static final userName = ValueNotifier<String?>(null);
  static final interests = ValueNotifier<List<String>>([]);
  static final onboardingDone = ValueNotifier<bool>(false);

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    try {
      final session = SupabaseService.client.auth.currentSession;
      _syncFromSession(session);

      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        _syncFromSession(data.session);
      });
    } catch (_) {}
  }

  static void _syncFromSession(Session? session) {
    if (session != null) {
      token.value = session.accessToken;
      userEmail.value = session.user.email;
      userName.value = session.user.userMetadata?['full_name'] as String? ?? session.user.email ?? 'User';
      isLoggedIn.value = true;
      interests.value = (session.user.userMetadata?['interests'] as List?)?.cast<String>() ?? [];
      onboardingDone.value = session.user.userMetadata?['onboarding_completed'] == true;
    } else {
      token.value = null;
      userEmail.value = null;
      userName.value = null;
      isLoggedIn.value = false;
      onboardingDone.value = false;
      interests.value = [];
    }
  }

  static void login(String t, String email, String name) {
    token.value = t;
    userEmail.value = email;
    userName.value = name;
    isLoggedIn.value = true;
  }

  static Future<String?> completeOnboarding(List<String> selectedInterests) async {
    interests.value = List.from(selectedInterests);
    onboardingDone.value = true;
    final err = await SupabaseService.updateMetadata({
      'interests': selectedInterests,
      'onboarding_completed': true,
    });
    return err;
  }

  static Future<String?> logout() async {
    final err = await SupabaseService.signOut();
    token.value = null;
    userEmail.value = null;
    userName.value = null;
    isLoggedIn.value = false;
    onboardingDone.value = false;
    interests.value = [];
    return err;
  }
}
