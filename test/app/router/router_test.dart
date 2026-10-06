import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/router/app_router.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/auth/presentation/screens/login_screen.dart';
import 'package:gallery/features/auth/presentation/screens/splash_screen.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('GoRouter Guard & Redirect Logic', () {
    late MockAuthRepository mockRepo;
    late AuthCubit authCubit;
    late ThemeCubit themeCubit;
    late MockPhotoRepository mockPhotoRepo;
    late GalleryCubit galleryCubit;

    setUp(() {
      mockRepo = MockAuthRepository(simulatedDelay: Duration.zero);
      authCubit = AuthCubit(authRepository: mockRepo);
      themeCubit = ThemeCubit();
      mockPhotoRepo = MockPhotoRepository(photos: const []);
      galleryCubit = GalleryCubit(photoRepository: mockPhotoRepo);
    });

    tearDown(() {
      authCubit.close();
      themeCubit.close();
      galleryCubit.close();
      mockRepo.dispose();
    });

    Widget createTestApp(GoRouter router) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('initial startup loads SplashScreen while AuthInitial', (
      tester,
    ) async {
      final router = AppRouter.createRouter(authCubit);

      await tester.pumpWidget(createTestApp(router));
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets(
      'unauthenticated user redirected to LoginScreen from protected /home',
      (tester) async {
        // Resolve initial check to Unauthenticated
        await authCubit.checkAuthSession();

        final router = AppRouter.createRouter(authCubit);
        await tester.pumpWidget(createTestApp(router));
        await tester.pump();

        // Attempt to navigate to protected /home
        router.go(AppRouter.homePath);
        await tester.pump();

        // Guard intercepts and directs to LoginScreen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(router.state.matchedLocation, equals(AppRouter.loginPath));
      },
    );

    testWidgets(
      'authenticated user redirected to /home when attempting /login',
      (tester) async {
        final seededRepo = MockAuthRepository(
          simulatedDelay: Duration.zero,
          initialUser: const AuthUser(
            id: '1',
            email: 'demo@gallery.ai',
            displayName: 'Demo User',
          ),
        );
        final seededCubit = AuthCubit(authRepository: seededRepo);
        await seededCubit.checkAuthSession();

        final router = AppRouter.createRouter(seededCubit);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: seededCubit),
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<GalleryCubit>.value(value: galleryCubit),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();

        // Attempt to navigate to /login
        router.go(AppRouter.loginPath);
        await tester.pump();

        // Guard redirects to /home
        expect(router.state.matchedLocation, equals(AppRouter.homePath));

        await seededCubit.close();
        seededRepo.dispose();
      },
    );

    testWidgets('logging out on /home redirects immediately to /login', (
      tester,
    ) async {
      await authCubit.login(email: 'demo@gallery.ai', password: 'password123');

      final router = AppRouter.createRouter(authCubit);
      await tester.pumpWidget(createTestApp(router));
      await tester.pump();

      expect(router.state.matchedLocation, equals(AppRouter.homePath));

      await authCubit.logout();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(router.state.matchedLocation, equals(AppRouter.loginPath));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
