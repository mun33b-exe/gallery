import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_state.dart';

void main() {
  group('AuthCubit State Transitions', () {
    late MockAuthRepository mockRepo;
    late AuthCubit authCubit;

    setUp(() {
      mockRepo = MockAuthRepository(simulatedDelay: Duration.zero);
      authCubit = AuthCubit(authRepository: mockRepo);
    });

    tearDown(() {
      authCubit.close();
      mockRepo.dispose();
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, equals(const AuthInitial()));
    });

    test(
      'checkAuthSession emits Unauthenticated when no session exists',
      () async {
        await authCubit.checkAuthSession();
        expect(authCubit.state, equals(const Unauthenticated()));
      },
    );

    test(
      'checkAuthSession emits Authenticated when pre-authenticated user exists',
      () async {
        final seededRepo = MockAuthRepository(
          simulatedDelay: Duration.zero,
          initialUser: const AuthUser(
            id: 'seeded_1',
            email: 'seeded@gallery.ai',
            displayName: 'Seeded User',
          ),
        );
        final seededCubit = AuthCubit(authRepository: seededRepo);

        await seededCubit.checkAuthSession();
        expect(
          seededCubit.state,
          equals(
            const Authenticated(
              user: AuthUser(
                id: 'seeded_1',
                email: 'seeded@gallery.ai',
                displayName: 'Seeded User',
              ),
            ),
          ),
        );

        await seededCubit.close();
        seededRepo.dispose();
      },
    );

    test(
      'login with valid demo credentials succeeds and emits Authenticated',
      () async {
        await authCubit.login(
          email: 'demo@gallery.ai',
          password: 'password123',
        );

        expect(authCubit.state, isA<Authenticated>());
        final authState = authCubit.state as Authenticated;
        expect(authState.user.email, equals('demo@gallery.ai'));
        expect(authState.user.displayName, equals('Demo Creator'));
      },
    );

    test('login with unknown email emits AuthError', () async {
      await authCubit.login(
        email: 'unknown@gallery.ai',
        password: 'password123',
      );

      expect(authCubit.state, isA<AuthError>());
      final errorState = authCubit.state as AuthError;
      expect(errorState.message, contains('No account found'));
    });

    test('login with invalid password emits AuthError', () async {
      await authCubit.login(
        email: 'demo@gallery.ai',
        password: 'wrong_password',
      );

      expect(authCubit.state, isA<AuthError>());
      final errorState = authCubit.state as AuthError;
      expect(errorState.message, contains('Incorrect password'));
    });

    test('register new account succeeds and emits Authenticated', () async {
      await authCubit.register(
        displayName: 'Alice Wonderland',
        email: 'alice@example.com',
        password: 'securepassword',
      );

      expect(authCubit.state, isA<Authenticated>());
      final authState = authCubit.state as Authenticated;
      expect(authState.user.email, equals('alice@example.com'));
      expect(authState.user.displayName, equals('Alice Wonderland'));
    });

    test('register with existing email emits AuthError', () async {
      await authCubit.register(
        displayName: 'Duplicate User',
        email: 'demo@gallery.ai',
        password: 'password123',
      );

      expect(authCubit.state, isA<AuthError>());
      final errorState = authCubit.state as AuthError;
      expect(errorState.message, contains('already exists'));
    });

    test('register with short password emits AuthError', () async {
      await authCubit.register(
        displayName: 'Short Pass User',
        email: 'short@example.com',
        password: '123',
      );

      expect(authCubit.state, isA<AuthError>());
      final errorState = authCubit.state as AuthError;
      expect(errorState.message, contains('at least 6 characters'));
    });

    test('logout transitions Authenticated to Unauthenticated', () async {
      await authCubit.login(email: 'demo@gallery.ai', password: 'password123');
      expect(authCubit.state, isA<Authenticated>());

      await authCubit.logout();
      expect(authCubit.state, equals(const Unauthenticated()));
    });

    test('resetPassword emits PasswordResetSent on registered email', () async {
      await authCubit.resetPassword(email: 'demo@gallery.ai');
      expect(
        authCubit.state,
        equals(const PasswordResetSent(email: 'demo@gallery.ai')),
      );
    });

    test('clearError resets AuthError to Unauthenticated', () {
      authCubit.emit(const AuthError(message: 'Some error'));
      expect(authCubit.state, isA<AuthError>());

      authCubit.clearError();
      expect(authCubit.state, equals(const Unauthenticated()));
    });
  });
}
