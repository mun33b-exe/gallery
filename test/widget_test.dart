import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/app.dart';
import 'package:gallery/features/auth/data/mock_auth_repository.dart';
import 'package:gallery/features/auth/presentation/screens/login_screen.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';

void main() {
  testWidgets(
    'GalleryApp end-to-end flow: splash -> login -> demo sign-in -> gallery -> settings -> logout',
    (tester) async {
      final mockAuthRepo = MockAuthRepository(simulatedDelay: Duration.zero);
      final mockPhotoRepo = MockPhotoRepository(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        GalleryApp(
          authRepository: mockAuthRepo,
          photoRepository: mockPhotoRepo,
        ),
      );
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

      // User is authenticated and GoRouter redirects to /home (GalleryScreen)
      expect(find.byType(GalleryScreen), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);

      // Allow thumbnails to load
      await tester.pump();
      expect(find.byType(PhotoThumbnailTile), findsWidgets);

      // Tap first thumbnail to open PhotoViewerScreen
      await tester.tap(find.byType(PhotoThumbnailTile).first);
      await tester.pumpAndSettle();

      expect(find.byType(PhotoViewerScreen), findsOneWidget);
      expect(find.text('1 of 40'), findsOneWidget);

      // Tap back in PhotoViewerScreen
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Returned to GalleryScreen
      expect(find.byType(GalleryScreen), findsOneWidget);

      // Tap Settings button in header to visit AppShell
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('AI Gallery Foundation'), findsOneWidget);
      expect(find.text('Demo Creator'), findsOneWidget);

      // Tap Sign Out button
      await tester.tap(find.text('Sign Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Redirected back to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      mockAuthRepo.dispose();
    },
  );
}
