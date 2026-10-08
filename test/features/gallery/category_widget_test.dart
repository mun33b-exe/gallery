import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/home_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/category_filter_bar.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';

void main() {
  group('GalleryScreen Category Widget Tests', () {
    late MockPhotoRepository mockRepo;
    late GalleryCubit galleryCubit;
    late List<PhotoModel> testPhotos;

    setUp(() {
      testPhotos = [
        PhotoModel(
          id: 'p1',
          title: 'IMG_0001.JPG',
          width: 1920,
          height: 1080,
          createDateTime: DateTime(2024, 10, 5, 14, 30),
          isFavorite: true,
        ),
        PhotoModel(
          id: 'p2',
          title: 'IMG_0002.JPG',
          width: 1920,
          height: 1080,
          createDateTime: DateTime(2024, 10, 6, 9, 15),
          isFavorite: false,
        ),
      ];

      mockRepo = MockPhotoRepository(photos: testPhotos);
      galleryCubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await galleryCubit.close();
    });

    Widget createTestGallery() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      );
    }

    testWidgets('renders CategoryFilterBar with chips and counts', (
      tester,
    ) async {
      await tester.pumpWidget(createTestGallery());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryFilterBar), findsOneWidget);
      expect(find.text('All Photos (2)'), findsOneWidget);
      expect(find.text('Favorites (1)'), findsOneWidget);
      expect(find.text('Screenshots (0)'), findsOneWidget);
      expect(find.byType(PhotoThumbnailTile), findsNWidgets(2));
    });

    testWidgets('tapping Favorites filter chip updates visible photos', (
      tester,
    ) async {
      await tester.pumpWidget(createTestGallery());
      await tester.pumpAndSettle();

      expect(find.byType(PhotoThumbnailTile), findsNWidgets(2));

      // Tap on Favorites chip
      await tester.tap(find.text('Favorites (1)'));
      await tester.pumpAndSettle();

      // Only 1 photo (the favorite) is rendered
      expect(find.byType(PhotoThumbnailTile), findsOneWidget);
    });

    testWidgets(
      'selecting empty category renders contextual empty state and View All Photos button',
      (tester) async {
        await tester.pumpWidget(createTestGallery());
        await tester.pumpAndSettle();

        // Scroll Screenshots chip into view and tap
        await tester.ensureVisible(find.text('Screenshots (0)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Screenshots (0)'));
        await tester.pumpAndSettle();

        // Contextual empty state is rendered
        expect(find.text('No Screenshots Found'), findsOneWidget);
        expect(
          find.text('No screenshots were found on your device.'),
          findsOneWidget,
        );
        expect(find.text('View All Photos'), findsOneWidget);

        // CategoryFilterBar remains visible so the user can easily switch categories
        expect(find.byType(CategoryFilterBar), findsOneWidget);

        // Tapping 'View All Photos' returns to all photos
        await tester.tap(find.text('View All Photos'));
        await tester.pumpAndSettle();

        expect(find.byType(PhotoThumbnailTile), findsNWidgets(2));
        await tester.drag(find.byType(CategoryFilterBar), const Offset(500, 0));
        await tester.pumpAndSettle();
        expect(find.text('All Photos (2)'), findsOneWidget);
      },
    );
  });
}
