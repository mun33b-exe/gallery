import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Concrete production implementation of [AuthRepository] backed by Supabase.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository({required SupabaseClient supabaseClient})
    : _client = supabaseClient;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Future<AuthUser?> checkCurrentSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        return _mapUser(session.user);
      }
      return null;
    } on SocketException {
      return null;
    } on AuthRetryableFetchException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Authentication failed. Please verify credentials.');
      }

      return _mapUser(user);
    } catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': displayName.trim()},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      return _mapUser(user);
    } catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Never _handleAuthError(Object error) {
    if (error is SocketException ||
        error is AuthRetryableFetchException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup') ||
        error.toString().contains('Network connection') ||
        error.toString().contains('ClientException')) {
      throw Exception(
        'Network connection unavailable. Please check your internet connection.',
      );
    }
    if (error is AuthException) {
      if (error.message.toLowerCase().contains('failed host lookup') ||
          error.message.toLowerCase().contains('socketexception') ||
          error.message.toLowerCase().contains('network')) {
        throw Exception(
          'Network connection unavailable. Please check your internet connection.',
        );
      }
      throw Exception(error.message);
    }
    if (error is Exception) {
      throw error;
    }
    throw Exception(error.toString());
  }

  AuthUser _mapUser(User user) {
    final metadata = user.userMetadata ?? {};
    final displayName =
        (metadata['display_name'] as String?) ??
        (metadata['full_name'] as String?) ??
        (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'User');

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName,
    );
  }
}
