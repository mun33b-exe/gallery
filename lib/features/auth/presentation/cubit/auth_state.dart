import 'package:equatable/equatable.dart';

import '../../domain/auth_user.dart';

/// Base state for authentication.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state while determining if a session exists (e.g., during splash).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is not logged in.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication operation is currently in progress.
class Authenticating extends AuthState {
  const Authenticating();
}

/// User is successfully authenticated.
class Authenticated extends AuthState {
  final AuthUser user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// An authentication error occurred.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Password reset request sent successfully.
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}
