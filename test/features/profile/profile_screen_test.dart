import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/profile/domain/user_entitlement.dart';
import 'package:gallery/features/profile/presentation/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    late MockAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() async {
      authRepo = MockAuthRepository(
        initialUser: const AuthUser(
          id: 'test_user_1',
          email: 'sarah.connor@example.com',
          displayName: 'Sarah Connor',
        ),
      );
      authCubit = AuthCubit(authRepository: authRepo);
      await authCubit.checkAuthSession();
    });

    tearDown(() async {
      await authCubit.close();
      authRepo.dispose();
    });

    Widget createProfileTestApp({
      UserEntitlement entitlement = UserEntitlement.freeTier,
      GoRouter? router,
    }) {
      final testRouter =
          router ??
          GoRouter(
            initialLocation: '/profile',
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    ProfileScreen(entitlement: entitlement),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                    const Scaffold(body: Text('Settings Destination')),
              ),
            ],
          );

      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      );
    }

    testWidgets(
      'renders user information with avatar initials, name, and email',
      (tester) async {
        await tester.pumpWidget(createProfileTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Sarah Connor'), findsOneWidget);
        expect(find.text('sarah.connor@example.com'), findsOneWidget);
        expect(find.text('S'), findsOneWidget); // Avatar initial
        expect(find.text('Profile'), findsOneWidget);
      },
    );

    testWidgets(
      'renders Free Plan entitlement badge and preview feature cards',
      (tester) async {
        await tester.pumpWidget(
          createProfileTestApp(entitlement: UserEntitlement.freeTier),
        );
        await tester.pumpAndSettle();

        expect(find.text('Free Plan'), findsOneWidget);
        expect(
          find.textContaining('Your account is currently on the Free Plan'),
          findsOneWidget,
        );
        expect(find.text('Upcoming Pro Features'), findsOneWidget);
        expect(find.text('Unlimited On-Device AI Search'), findsOneWidget);
        expect(find.text('Lossless RAW & HDR Export'), findsOneWidget);
        expect(find.text('Semantic Face & Event Clustering'), findsOneWidget);
        expect(find.text('Preview'), findsNWidgets(3));
      },
    );

    testWidgets('renders Pro Member badge when entitlement is premium', (
      tester,
    ) async {
      await tester.pumpWidget(
        createProfileTestApp(entitlement: UserEntitlement.premiumTier),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pro Member'), findsOneWidget);
    });

    testWidgets(
      'tapping Sign Out shows confirmation dialog, confirming triggers logout',
      (tester) async {
        await tester.pumpWidget(createProfileTestApp());
        await tester.pumpAndSettle();

        expect(authRepo.currentUser, isNotNull);

        final signOutButton = find.text('Sign Out');
        expect(signOutButton, findsOneWidget);

        await tester.ensureVisible(signOutButton);
        await tester.tap(signOutButton);
        await tester.pumpAndSettle();

        // Confirmation dialog is visible
        expect(
          find.text('Are you sure you want to sign out of your account?'),
          findsOneWidget,
        );

        // Tap confirm in dialog
        final confirmButton = find.widgetWithText(TextButton, 'Sign Out');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        expect(authRepo.currentUser, isNull);
      },
    );

    testWidgets('cancelling sign out dialog does not trigger logout', (
      tester,
    ) async {
      await tester.pumpWidget(createProfileTestApp());
      await tester.pumpAndSettle();

      final signOutButton = find.text('Sign Out');
      await tester.ensureVisible(signOutButton);
      await tester.tap(signOutButton);
      await tester.pumpAndSettle();

      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(authRepo.currentUser, isNotNull);
    });

    testWidgets('settings icon in header navigates to /settings', (
      tester,
    ) async {
      await tester.pumpWidget(createProfileTestApp());
      await tester.pumpAndSettle();

      final settingsIcon = find.byIcon(Icons.settings_outlined);
      expect(settingsIcon, findsOneWidget);

      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      expect(find.text('Settings Destination'), findsOneWidget);
    });
  });
}
