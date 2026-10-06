import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/app_shell.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  group('AppShell Adaptive Rendering (Rule 5.3 Audit)', () {
    late ThemeCubit themeCubit;
    late MockAuthRepository mockRepo;
    late AuthCubit authCubit;

    setUp(() {
      themeCubit = ThemeCubit();
      mockRepo = MockAuthRepository(
        simulatedDelay: Duration.zero,
        initialUser: const AuthUser(
          id: 'test_1',
          email: 'test@gallery.ai',
          displayName: 'Test User',
        ),
      );
      authCubit = AuthCubit(authRepository: mockRepo);
    });

    tearDown(() {
      themeCubit.close();
      authCubit.close();
      mockRepo.dispose();
    });

    Widget buildThemedAppShell(TargetPlatform platform) {
      final baseTheme = AppThemes.defaultTheme.themeData;
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp(
          theme: baseTheme.copyWith(platform: platform),
          home: const AppShell(),
        ),
      );
    }

    testWidgets('AppShell renders Cupertino widgets on iOS (Rule 5.3)', (
      tester,
    ) async {
      await tester.pumpWidget(buildThemedAppShell(TargetPlatform.iOS));
      await tester.pump();

      // Verify that the loading indicator is CupertinoActivityIndicator on iOS
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify that buttons in the showcase use CupertinoButton
      expect(find.byType(CupertinoButton), findsWidgets);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('AppShell renders Material widgets on Android (Rule 5.3)', (
      tester,
    ) async {
      await tester.pumpWidget(buildThemedAppShell(TargetPlatform.android));
      await tester.pump();

      // Verify that the loading indicator is CircularProgressIndicator on Android
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);

      // Verify that buttons in the showcase use ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });
  });
}
