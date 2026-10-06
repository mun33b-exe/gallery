import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/app.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets(
    'GalleryApp end-to-end auth flow: splash -> login -> demo sign-in -> home -> logout',
    (tester) async {
      final mockRepo = MockAuthRepository(simulatedDelay: Duration.zero);

      await tester.pumpWidget(GalleryApp(authRepository: mockRepo));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Session check runs and redirects unauthenticated state to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      // Tap demo credentials helper button
      await tester.tap(find.text('Fill Demo Account (demo@gallery.ai)'));
      await tester.pump();

      // Tap 'Sign In'
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // User is now authenticated and GoRouter redirects to /home (AppShell)
      expect(find.text('AI Gallery Foundation'), findsOneWidget);
      expect(find.text('Demo Creator'), findsOneWidget);

      // Tap Sign Out button
      await tester.tap(find.text('Sign Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Redirected back to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      mockRepo.dispose();
    },
  );
}
