import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/gallery/presentation/screens/photo_viewer_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central routing configuration with route guards.
class AppRouter {
  AppRouter._();

  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String homePath = '/home';
  static const String photoViewerPath = '/photo-viewer';
  static const String searchPath = '/search';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: splashPath,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final location = state.matchedLocation;

        final isInitializing = authState is AuthInitial;
        final isAuthenticated = authState is Authenticated;
        final isAuthRoute =
            location == loginPath ||
            location == registerPath ||
            location == forgotPasswordPath;
        final isSplash = location == splashPath;

        // 1. While checking initial session, stay on splash screen
        if (isInitializing) {
          return isSplash ? null : splashPath;
        }

        // 2. Unauthenticated users cannot view protected routes
        if (!isAuthenticated) {
          if (isAuthRoute) {
            return null; // Allow login, register, forgot-password
          }
          return loginPath;
        }

        // 3. Authenticated users are redirected away from auth pages and splash to /home
        if (isAuthenticated) {
          if (isAuthRoute || isSplash) {
            return homePath;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: splashPath,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: loginPath,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: registerPath,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgotPasswordPath,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: homePath,
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: photoViewerPath,
          builder: (context, state) {
            final args = state.extra as PhotoViewerArgs;
            final photoRepo = context.read<GalleryCubit>().photoRepository;
            return PhotoViewerScreen(args: args, photoRepository: photoRepo);
          },
        ),
        GoRoute(
          path: searchPath,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: profilePath,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: settingsPath,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
