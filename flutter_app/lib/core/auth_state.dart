import 'package:flutter/material.dart';

class AuthState {
  static final isLoggedIn = ValueNotifier<bool>(false);
  static final token = ValueNotifier<String?>(null);
  static final userEmail = ValueNotifier<String?>(null);
  static final userName = ValueNotifier<String?>(null);
  static final interests = ValueNotifier<List<String>>([]);
  static final onboardingDone = ValueNotifier<bool>(false);

  static void login(String t, String email, String name) {
    token.value = t;
    userEmail.value = email;
    userName.value = name;
    isLoggedIn.value = true;
  }

  static void logout() {
    token.value = null;
    userEmail.value = null;
    userName.value = null;
    isLoggedIn.value = false;
    onboardingDone.value = false;
    interests.value = [];
  }
}
