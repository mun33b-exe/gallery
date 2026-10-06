import 'dart:async';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// In-memory mock authentication repository.
/// Allows end-to-end verification of authentication flows without a live backend.
class MockAuthRepository implements AuthRepository {
  final Duration simulatedDelay;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  // In-memory registered user database: email -> {password, user}
  final Map<String, _MockUserRecord> _users = {
    'demo@gallery.ai': _MockUserRecord(
      password: 'password123',
      user: const AuthUser(
        id: 'usr_demo_1',
        email: 'demo@gallery.ai',
        displayName: 'Demo Creator',
      ),
    ),
  };

  MockAuthRepository({
    this.simulatedDelay = const Duration(milliseconds: 300),
    AuthUser? initialUser,
  }) : _currentUser = initialUser;

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser?> checkCurrentSession() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final normalizedEmail = email.trim().toLowerCase();
    final record = _users[normalizedEmail];

    if (record == null) {
      throw Exception('No account found with this email address.');
    }

    if (record.password != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    _currentUser = record.user;
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (_users.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    final newUser = AuthUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: displayName.trim().isEmpty
          ? 'Photographer'
          : displayName.trim(),
    );

    _users[normalizedEmail] = _MockUserRecord(
      password: password,
      user: newUser,
    );
    _currentUser = newUser;
    _authStateController.add(_currentUser);
    return newUser;
  }

  @override
  Future<void> logout() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    final normalizedEmail = email.trim().toLowerCase();
    if (!_users.containsKey(normalizedEmail)) {
      throw Exception('No account found with that email address.');
    }
    // Simulation: reset link sent successfully
  }

  void dispose() {
    _authStateController.close();
  }
}

class _MockUserRecord {
  final String password;
  final AuthUser user;

  _MockUserRecord({required this.password, required this.user});
}
