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
      'iOS target renders CupertinoNavigationBar, CupertinoListSection, and Cupertino icons',
      (tester) async {
        await tester.pumpWidget(
          createAdaptiveSettingsApp(platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.byType(CupertinoNavigationBar), findsOneWidget);
        expect(find.byType(AppBar), findsNothing);

        // List section & tiles
        expect(find.byType(CupertinoListSection), findsOneWidget);
        expect(find.byType(CupertinoListTile), findsWidgets);
        expect(find.byType(RadioListTile<String>), findsNothing);

        // Cupertino Icons
        expect(find.byIcon(CupertinoIcons.shield_fill), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.photo_on_rectangle), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_forward), findsOneWidget);
      },
    );

    testWidgets(
      'Android target renders Material AppBar, RadioListTiles, and Material icons',
      (tester) async {
        await tester.pumpWidget(
          createAdaptiveSettingsApp(platform: TargetPlatform.android),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(CupertinoNavigationBar), findsNothing);

        // Radio List tiles
        expect(find.byType(RadioListTile<String>), findsWidgets);
        expect(find.byType(CupertinoListSection), findsNothing);

        // Material Icons
        expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
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
