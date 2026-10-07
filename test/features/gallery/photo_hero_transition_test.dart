import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hero Transition Tests', () {
    late PhotoModel testPhoto;
    late MockPhotoRepository mockRepo;
    late ThemeCubit themeCubit;

    setUp(() {
      testPhoto = PhotoModel(
        id: 'hero_photo_42',
        title: 'Sunset.jpg',
        width: 1920,
        height: 1080,
        createDateTime: DateTime(2025, 6, 1),
      );
      mockRepo = MockPhotoRepository(
        photos: [testPhoto],
        simulatedDelay: Duration.zero,
      );
      themeCubit = ThemeCubit();
    });

    tearDown(() async {
      await themeCubit.close();
    });

    testWidgets('PhotoThumbnailTile renders Hero tagged with photo id', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: PhotoThumbnailTile(
                photo: testPhoto,
                photoRepository: mockRepo,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final heroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'photo_hero_photo_42',
      );
      expect(heroFinder, findsOneWidget);
    });

    testWidgets('PhotoViewerScreen renders Hero tagged with same photo id', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoViewerScreen(
            args: PhotoViewerArgs(photos: [testPhoto], initialIndex: 0),
            photoRepository: mockRepo,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final heroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'photo_hero_photo_42',
      );
      expect(heroFinder, findsOneWidget);
    });
  });
}
