import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import 'auth_state.dart';

/// Cubit managing authentication state, session validation, and user actions.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit({required this.authRepository}) : super(const AuthInitial()) {
    _authSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user: user));
      } else if (state is! AuthInitial && state is! Authenticating) {
        emit(const Unauthenticated());
      }
    });
  }

  /// Checks whether an existing session is valid (invoked by Splash screen).
  Future<void> checkAuthSession() async {
    try {
      final user = await authRepository.checkCurrentSession();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  /// Logs in with email and password.
  Future<void> login({required String email, required String password}) async {
    emit(const Authenticating());
    try {
      final user = await authRepository.login(email: email, password: password);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _cleanErrorMessage(e)));
    }
  }

  /// Registers a new user.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const Authenticating());
    try {
      final user = await authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _cleanErrorMessage(e)));
    }
  }

  /// Logs out the active user.
  Future<void> logout() async {
    emit(const Authenticating());
    try {
      await authRepository.logout();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(message: _cleanErrorMessage(e)));
    }
  }

  /// Requests a password reset.
  Future<void> resetPassword({required String email}) async {
    emit(const Authenticating());
    try {
      await authRepository.resetPassword(email: email);
      emit(PasswordResetSent(email: email));
    } catch (e) {
      emit(AuthError(message: _cleanErrorMessage(e)));
    }
  }

  /// Clears any transient error state back to unauthenticated.
  void clearError() {
    if (state is AuthError || state is PasswordResetSent) {
      emit(const Unauthenticated());
    }
  }

  String _cleanErrorMessage(Object error) {
    final raw = error.toString();
    if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup') ||
        raw.contains('AuthRetryableFetchException') ||
        raw.contains('Network connection unavailable')) {
      return 'Network connection unavailable. Please check your internet connection.';
    }
    if (raw.startsWith('Exception: ')) {
      return raw.substring(11);
    }
    return raw;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
