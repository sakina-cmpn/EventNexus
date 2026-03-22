import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  bool get isSignedIn => _client.auth.currentSession != null;

  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _toAuthUser(user);
  }

  // ── REGISTER ─────────────────────────────────────────────
  Future<AppUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[Auth] Supabase signUp started');
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      final user = response.user;
      if (user == null) throw 'Signup failed';

      debugPrint('[Auth] Supabase user created: ${user.id}');
      return _toAuthUser(user);
    } on AuthException catch (e) {
      debugPrint('[Auth] Supabase AuthException (signUp): ${e.message}');
      throw e.message;
    } catch (e) {
      debugPrint('[Auth] Supabase signUp error: $e');
      throw 'Something went wrong';
    }
  }

  // ── LOGIN ────────────────────────────────────────────────
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[Auth] Supabase signIn started');
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) throw 'Login failed';

      debugPrint('[Auth] Supabase login success: ${user.id}');
      return _toAuthUser(user);
    } on AuthException catch (e) {
      debugPrint('[Auth] Supabase AuthException (signIn): ${e.message}');
      throw e.message;
    } catch (e) {
      debugPrint('[Auth] Supabase signIn error: $e');
      throw 'Something went wrong';
    }
  }

  // ── RESET PASSWORD ────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      debugPrint('[Auth] Supabase reset email sent');
    } on AuthException catch (e) {
      debugPrint('[Auth] Supabase AuthException (reset): ${e.message}');
      throw e.message;
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      debugPrint('[Auth] Supabase verify OTP started');
      await _client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.signup,
      );
    } on AuthException catch (e) {
      // Some Supabase projects send an "email OTP" instead of "signup OTP".
      debugPrint('[Auth] Supabase verifyOTP (signup) failed: ${e.message}');
      try {
        await _client.auth.verifyOTP(
          email: email.trim(),
          token: token.trim(),
          type: OtpType.email,
        );
      } on AuthException catch (e2) {
        debugPrint('[Auth] Supabase verifyOTP (email) failed: ${e2.message}');
        throw e2.message;
      }
    }
  }

  Future<void> resendEmailOtp(String email) async {
    try {
      debugPrint('[Auth] Supabase resend OTP started');
      await _client.auth.resend(type: OtpType.signup, email: email.trim());
    } on AuthException catch (e) {
      debugPrint('[Auth] Supabase resend (signup) failed: ${e.message}');
      try {
        await _client.auth.resend(type: OtpType.email, email: email.trim());
      } on AuthException catch (e2) {
        debugPrint('[Auth] Supabase resend (email) failed: ${e2.message}');
        throw e2.message;
      }
    }
  }

  // ── SIGN OUT ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AppUser _toAuthUser(User user) {
    final meta = user.userMetadata ?? const <String, dynamic>{};
    final name =
        (meta['name'] ?? meta['full_name'] ?? meta['display_name'])?.toString();

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: name,
    );
  }
}
