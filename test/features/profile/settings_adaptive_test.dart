import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/profile/presentation/screens/profile_screen.dart';
import 'package:gallery/features/profile/presentation/screens/settings_screen.dart';

void main() {
  group('Settings & Profile Adaptive Presentation (Rule 5.3)', () {
    late ThemeCubit themeCubit;
    late MockAuthRepository authRepo;
    late AuthCubit authCubit;
    late MockPhotoRepository photoRepo;
    late GalleryCubit galleryCubit;

    setUp(() async {
      themeCubit = ThemeCubit();
      authRepo = MockAuthRepository(
        initialUser: const AuthUser(
          id: 'test_user_adaptive',
          email: 'adaptive@example.com',
          displayName: 'Adaptive User',
        ),
      );
      authCubit = AuthCubit(authRepository: authRepo);
      await authCubit.checkAuthSession();
      photoRepo = MockPhotoRepository(simulatedDelay: Duration.zero);
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

    Widget createAdaptiveSettingsApp({required TargetPlatform platform}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: platform),
          home: const SettingsScreen(),
        ),
      );
    }

    Widget createAdaptiveProfileApp({required TargetPlatform platform}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: platform),
          home: const ProfileScreen(),
        ),
      );
    }

    testWidgets(
      'SettingsScreen renders modern custom iOS-inspired layout safely across iOS and Android',
      (tester) async {
        setLargeViewport(tester);

        for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
          await tester.pumpWidget(
            createAdaptiveSettingsApp(platform: platform),
          );
          await tester.pumpAndSettle();

          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('User Account & Entitlements'), findsOneWidget);
          expect(find.text('Appearance & Themes'), findsOneWidget);
          expect(find.text('Privacy & Permissions'), findsOneWidget);
          expect(find.text('About Application'), findsOneWidget);
          expect(find.text('Sign Out'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'SettingsScreen renders CupertinoAlertDialog on iOS vs Material AlertDialog on Android on sign out',
      (tester) async {
        setLargeViewport(tester);

        // 1. Test iOS dialog
        await tester.pumpWidget(
          createAdaptiveSettingsApp(platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        final signOutBtnIOS = find.text('Sign Out');
        await tester.tap(signOutBtnIOS);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Cancel'));
        await tester.pumpAndSettle();

        // 2. Test Android dialog
        await tester.pumpWidget(
          createAdaptiveSettingsApp(platform: TargetPlatform.android),
        );
        await tester.pumpAndSettle();

        final signOutBtnAndroid = find.text('Sign Out');
        await tester.tap(signOutBtnAndroid);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(CupertinoAlertDialog), findsNothing);

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Profile screen renders CupertinoAlertDialog on iOS vs Material AlertDialog on Android on sign out',
      (tester) async {
        // Test iOS dialog
        await tester.pumpWidget(
          createAdaptiveProfileApp(platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        final signOutFinder = find.text('Sign Out');
        await tester.ensureVisible(signOutFinder);
        await tester.tap(signOutFinder);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Cancel'));
        await tester.pumpAndSettle();

        // Test Android dialog
        await tester.pumpWidget(
          createAdaptiveProfileApp(platform: TargetPlatform.android),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(signOutFinder);
        await tester.tap(signOutFinder);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(CupertinoAlertDialog), findsNothing);
      },
    );
  });
}
