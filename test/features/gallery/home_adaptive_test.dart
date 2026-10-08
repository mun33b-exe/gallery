import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/home_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/floating_library_nav_bar.dart';

void main() {
  group('HomeScreen Adaptive Presentation (Rule 5.3)', () {
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

    Widget createAdaptiveHomeTestApp(TargetPlatform platform) {
      final baseTheme = AppThemes.defaultTheme.themeData;
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp(
          theme: baseTheme.copyWith(platform: platform),
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('HomeScreen renders cleanly on Android platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        createAdaptiveHomeTestApp(TargetPlatform.android),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Your Library'), findsOneWidget);
      expect(find.byType(FloatingLibraryNavBar), findsOneWidget);
    });

    testWidgets('HomeScreen renders cleanly on iOS platform', (tester) async {
      await tester.pumpWidget(createAdaptiveHomeTestApp(TargetPlatform.iOS));
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Your Library'), findsOneWidget);
      expect(find.byType(FloatingLibraryNavBar), findsOneWidget);
    });
  });
}
