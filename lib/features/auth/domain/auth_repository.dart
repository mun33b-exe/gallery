import 'auth_user.dart';

/// Replaceable abstraction for authentication operations.
/// All UI and BLoC components interact solely with this interface.
abstract class AuthRepository {
  /// Stream emitting the active user or null on logout.
  Stream<AuthUser?> get authStateChanges;

  /// Synchronous getter for current user.
  AuthUser? get currentUser;

  /// Checks any persisted session (mocked or token-based).
  Future<AuthUser?> checkCurrentSession();

  /// Logs in with email and password.
  Future<AuthUser> login({required String email, required String password});

  /// Registers a new user.
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Logs out the active user.
  Future<void> logout();

  /// Requests a password reset email/link.
  Future<void> resetPassword({required String email});
}
