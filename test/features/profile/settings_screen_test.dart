import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/profile/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late ThemeCubit themeCubit;
    late MockAuthRepository authRepo;
    late AuthCubit authCubit;
    late MockPhotoRepository photoRepo;
    late GalleryCubit galleryCubit;

    setUp(() {
      themeCubit = ThemeCubit();
      authRepo = MockAuthRepository();
      authCubit = AuthCubit(authRepository: authRepo);
      photoRepo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
      );
      galleryCubit = GalleryCubit(photoRepository: photoRepo);
    });

    tearDown(() async {
      await themeCubit.close();
      await authCubit.close();
      await galleryCubit.close();
      authRepo.dispose();
    });

    void setLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Widget createSettingsTestApp({GoRouter? router}) {
      final testRouter =
          router ??
          GoRouter(
            initialLocation: '/settings',
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Scaffold(body: Text('Profile Destination')),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const Scaffold(body: Text('Home Destination')),
              ),
            ],
          );

      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      );
    }

    testWidgets(
      'renders all settings sections: profile shortcut, theme selection, privacy banner, and app info',
      (tester) async {
        setLargeViewport(tester);

        await tester.pumpWidget(createSettingsTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('User Account & Entitlements'), findsOneWidget);
        expect(find.text('Appearance & Themes'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Midnight Blue'), findsOneWidget);
        expect(find.text('Local-Only Privacy Guarantee'), findsOneWidget);
        expect(find.text('Photo Library Permission'), findsOneWidget);
        expect(find.text('About Application'), findsOneWidget);
        expect(find.text('1.0.0 (Build 1)'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
      },
    );

    testWidgets('tapping a theme option updates ThemeCubit state', (
      tester,
    ) async {
      setLargeViewport(tester);

      await tester.pumpWidget(createSettingsTestApp());
      await tester.pumpAndSettle();

      expect(themeCubit.state.selectedTheme.id, equals('dark'));

      final lightThemeTile = find.text('Light');
      expect(lightThemeTile, findsOneWidget);

      await tester.tap(lightThemeTile);
      await tester.pumpAndSettle();

      expect(themeCubit.state.selectedTheme.id, equals('light'));
    });

    testWidgets('tapping profile shortcut navigates to /profile', (
      tester,
    ) async {
      setLargeViewport(tester);

      await tester.pumpWidget(createSettingsTestApp());
      await tester.pumpAndSettle();

      final profileShortcut = find.text('User Account & Entitlements');
      expect(profileShortcut, findsOneWidget);

      await tester.tap(profileShortcut);
      await tester.pumpAndSettle();

      expect(find.text('Profile Destination'), findsOneWidget);
    });

    testWidgets('tapping profile avatar in header navigates to /profile', (
      tester,
    ) async {
      setLargeViewport(tester);

      await tester.pumpWidget(createSettingsTestApp());
      await tester.pumpAndSettle();

      final profileAvatar = find.bySemanticsLabel('Open profile');
      expect(profileAvatar, findsOneWidget);

      await tester.tap(profileAvatar);
      await tester.pumpAndSettle();

      expect(find.text('Profile Destination'), findsOneWidget);
    });

    testWidgets(
      'tapping Manage in permissions tile opens app settings on GalleryCubit',
      (tester) async {
        setLargeViewport(tester);

        await tester.pumpWidget(createSettingsTestApp());
        await tester.pumpAndSettle();

        expect(photoRepo.appSettingsOpened, isFalse);

        final manageButton = find.text('Manage');
        expect(manageButton, findsOneWidget);

        await tester.tap(manageButton);
        await tester.pumpAndSettle();

        expect(photoRepo.appSettingsOpened, isTrue);
      },
    );

    testWidgets(
      'tapping Sign Out shows confirmation dialog and cancels cleanly',
      (tester) async {
        setLargeViewport(tester);

        await tester.pumpWidget(createSettingsTestApp());
        await tester.pumpAndSettle();

        final signOutBtn = find.text('Sign Out');
        expect(signOutBtn, findsOneWidget);
        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to sign out of your account?'),
          findsOneWidget,
        );

        final cancelBtn = find.text('Cancel');
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to sign out of your account?'),
          findsNothing,
        );
      },
    );

    testWidgets('confirming Sign Out triggers AuthCubit.logout', (
      tester,
    ) async {
      setLargeViewport(tester);

      await tester.pumpWidget(createSettingsTestApp());
      await tester.pumpAndSettle();

      final signOutBtn = find.text('Sign Out');
      await tester.tap(signOutBtn);
      await tester.pumpAndSettle();

      // Find the Sign Out action inside the dialog
      final confirmSignOutBtn = find.widgetWithText(TextButton, 'Sign Out');
      await tester.tap(confirmSignOutBtn);
      await tester.pumpAndSettle();

      expect(authRepo.currentUser, isNull);
    });
  });
}
