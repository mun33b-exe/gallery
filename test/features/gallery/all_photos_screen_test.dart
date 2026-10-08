import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/all_photos_screen.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/category_filter_bar.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AllPhotosScreen Widget Tests', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() async {
      await themeCubit.close();
    });

    Widget createAllPhotosTestApp({required GalleryCubit galleryCubit}) {
      final testRouter = GoRouter(
        initialLocation: '/all-photos',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('Home Screen Target')),
          ),
          GoRoute(
            path: '/all-photos',
            builder: (context, state) => const AllPhotosScreen(),
          ),
          GoRoute(
            path: '/photo-viewer',
            builder: (context, state) {
              final args = state.extra as PhotoViewerArgs;
              return Scaffold(
                body: Text(
                  'PhotoViewer: index ${args.initialIndex}, count ${args.photos.length}',
                ),
              );
            },
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
      'renders All Photos header, count, filter bar, and 3-column media grid',
      (tester) async {
        final photos = List.generate(
          6,
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
        await cubit.loadInitialPhotos();

        await tester.pumpWidget(createAllPhotosTestApp(galleryCubit: cubit));
        await tester.pumpAndSettle();

        // Title & count
        expect(find.text('All Photos'), findsOneWidget);
        expect(find.text('6 Photos'), findsOneWidget);

        // Back button
        final backBtn = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Back',
        );
        expect(backBtn, findsOneWidget);

        // Category filter bar
        expect(find.byType(CategoryFilterBar), findsOneWidget);

        // Photo tiles
        expect(find.byType(PhotoThumbnailTile), findsNWidgets(6));

        await cubit.close();
      },
    );

    testWidgets(
      'tapping photo thumbnail tile opens PhotoViewerScreen with correct args',
      (tester) async {
        final photos = List.generate(
          4,
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
        await cubit.loadInitialPhotos();

        await tester.pumpWidget(createAllPhotosTestApp(galleryCubit: cubit));
        await tester.pumpAndSettle();

        final firstTile = find.byType(PhotoThumbnailTile).first;
        await tester.tap(firstTile);
        await tester.pumpAndSettle();

        expect(find.text('PhotoViewer: index 0, count 4'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets('renders empty view when photos list is empty', (tester) async {
      final repo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
        photos: [],
      );
      final cubit = GalleryCubit(photoRepository: repo);
      await cubit.loadInitialPhotos();

      await tester.pumpWidget(createAllPhotosTestApp(galleryCubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('No Photos Found'), findsOneWidget);
      expect(
        find.text('There are no photos in this category.'),
        findsOneWidget,
      );

      await cubit.close();
    });
  });
}
