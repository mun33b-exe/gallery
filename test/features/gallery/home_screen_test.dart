import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/home_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/floating_library_nav_bar.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:gallery/features/gallery/presentation/widgets/recent_asymmetric_grid.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('HomeScreen UI State Rendering', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() async {
      await themeCubit.close();
    });

    void setLargeViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Widget createHomeScreenTestApp({
      required GalleryCubit galleryCubit,
      VoidCallback? onOpenSettings,
    }) {
      final testRouter = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                HomeScreen(onOpenSettings: onOpenSettings),
          ),
          GoRoute(
            path: '/all-photos',
            builder: (context, state) =>
                const Scaffold(body: Text('All Photos Screen Target')),
          ),
        ],
      );

      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      );
    }

    testWidgets(
      'renders permission denied view and triggers settings action when denied',
      (tester) async {
        final deniedRepo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.denied,
          simulatedDelay: Duration.zero,
        );
        final cubit = GalleryCubit(photoRepository: deniedRepo);

        bool settingsTapped = false;

        await tester.pumpWidget(
          createHomeScreenTestApp(
            galleryCubit: cubit,
            onOpenSettings: () {
              settingsTapped = true;
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Photo Access Required'), findsOneWidget);
        expect(find.text('Open Device Settings'), findsOneWidget);

        await tester.tap(find.text('Open Device Settings'));
        await tester.pumpAndSettle();

        expect(settingsTapped, isTrue);
        expect(deniedRepo.appSettingsOpened, isTrue);

        await cubit.close();
      },
    );

    testWidgets('renders empty view when photo library has no photos', (
      tester,
    ) async {
      final emptyRepo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
        photos: [],
      );
      final cubit = GalleryCubit(photoRepository: emptyRepo);

      await tester.pumpWidget(createHomeScreenTestApp(galleryCubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('No Photos Found'), findsOneWidget);
      expect(find.text('Refresh Library'), findsOneWidget);

      await cubit.close();
    });

    testWidgets(
      'renders Your Library header, Assistant Card, suggestions, and strictly 5 recent photos when loaded',
      (tester) async {
        // Provide 12 photos to assert that RecentAsymmetricGrid caps at 5
        final photos = List.generate(
          12,
          (i) => PhotoModel(
            id: 'photo_$i',
            title: 'IMG_$i.JPG',
            width: 500,
            height: 500,
            createDateTime: DateTime.now(),
          ),
        );

        final repo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.granted,
          simulatedDelay: Duration.zero,
          photos: photos,
        );
        final cubit = GalleryCubit(photoRepository: repo);

        bool settingsTapped = false;

        await tester.pumpWidget(
          createHomeScreenTestApp(
            galleryCubit: cubit,
            onOpenSettings: () {
              settingsTapped = true;
            },
          ),
        );
        await tester.pumpAndSettle();

        // Header
        expect(find.text('Good morning,'), findsOneWidget);
        expect(find.text('Your Library'), findsOneWidget);

        // Assistant Card
        expect(find.text('Your personal Gallery Assistant'), findsOneWidget);
        expect(find.text('Search Photos'), findsOneWidget);
        expect(find.text('People'), findsOneWidget);
        expect(find.text('Places'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('Recently added'), findsOneWidget);

        // Suggestions & Recent
        expect(find.text('Suggestions'), findsOneWidget);
        expect(find.text('Recent'), findsOneWidget);
        final recentSeeAll = find.descendant(
          of: find.byType(RecentAsymmetricGrid),
          matching: find.text('See all'),
        );
        expect(recentSeeAll, findsOneWidget);

        // Assert strictly 5 recent photo tiles rendered in RecentAsymmetricGrid
        final recentTiles = find.descendant(
          of: find.byType(RecentAsymmetricGrid),
          matching: find.byType(PhotoThumbnailTile),
        );
        expect(recentTiles, findsNWidgets(5));

        // Tap settings profile avatar
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(settingsTapped, isTrue);

        await cubit.close();
      },
    );

    testWidgets(
      'tapping See all in Recent section navigates to All Photos screen',
      (tester) async {
        setLargeViewport(tester);
        final photos = List.generate(
          8,
          (i) => PhotoModel(
            id: 'photo_$i',
            title: 'IMG_$i.JPG',
            width: 500,
            height: 500,
            createDateTime: DateTime.now(),
          ),
        );

        final repo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.granted,
          simulatedDelay: Duration.zero,
          photos: photos,
        );
        final cubit = GalleryCubit(photoRepository: repo);

        await tester.pumpWidget(createHomeScreenTestApp(galleryCubit: cubit));
        await tester.pumpAndSettle();

        final seeAllButton = find.descendant(
          of: find.byType(RecentAsymmetricGrid),
          matching: find.text('See all'),
        );
        expect(seeAllButton, findsOneWidget);

        await tester.tap(seeAllButton);
        await tester.pumpAndSettle();

        expect(find.text('All Photos Screen Target'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets(
      'tapping Explore pill in bottom navigation bar navigates to All Photos screen',
      (tester) async {
        final photos = List.generate(
          8,
          (i) => PhotoModel(
            id: 'photo_$i',
            title: 'IMG_$i.JPG',
            width: 500,
            height: 500,
            createDateTime: DateTime.now(),
          ),
        );

        final repo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.granted,
          simulatedDelay: Duration.zero,
          photos: photos,
        );
        final cubit = GalleryCubit(photoRepository: repo);

        await tester.pumpWidget(createHomeScreenTestApp(galleryCubit: cubit));
        await tester.pumpAndSettle();

        final exploreTab = find.descendant(
          of: find.byType(FloatingLibraryNavBar),
          matching: find.text('Explore'),
        );
        expect(exploreTab, findsOneWidget);

        await tester.tap(exploreTab);
        await tester.pumpAndSettle();

        expect(find.text('All Photos Screen Target'), findsOneWidget);

        await cubit.close();
      },
    );
  });
}
