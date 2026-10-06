import 'package:equatable/equatable.dart';

/// Application-level user entity.
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String displayName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object?> get props => [id, email, displayName];
}
