import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/gallery_screen.dart';

void main() {
  group('GalleryScreen Adaptive Presentation (Rule 5.3)', () {
    late ThemeCubit themeCubit;
    late MockPhotoRepository mockRepo;
    late GalleryCubit galleryCubit;

    setUp(() {
      themeCubit = ThemeCubit();
      mockRepo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
      );
      galleryCubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await themeCubit.close();
      await galleryCubit.close();
    });

    Widget createAdaptiveGalleryTestApp(TargetPlatform platform) {
      final baseTheme = AppThemes.defaultTheme.themeData;
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp(
          theme: baseTheme.copyWith(platform: platform),
          home: const GalleryScreen(),
        ),
      );
    }

    testWidgets('GalleryScreen renders Material AppBar on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        createAdaptiveGalleryTestApp(TargetPlatform.android),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    testWidgets('GalleryScreen renders CupertinoNavigationBar on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(createAdaptiveGalleryTestApp(TargetPlatform.iOS));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    });
  });
}
