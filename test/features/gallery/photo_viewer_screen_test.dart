import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';

void main() {
  group('PhotoViewerScreen Widget Tests', () {
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
          isFavorite: false,
        ),
        PhotoModel(
          id: 'p2',
          title: 'IMG_0002.JPG',
          width: 3840,
          height: 2160,
          createDateTime: DateTime(2024, 10, 6, 9, 15),
          isFavorite: true,
        ),
        PhotoModel(
          id: 'p3',
          title: 'IMG_0003.JPG',
          width: 1280,
          height: 720,
          createDateTime: DateTime(2024, 10, 6, 16, 45),
          isFavorite: false,
        ),
      ];

      mockRepo = MockPhotoRepository(photos: testPhotos);
      galleryCubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await galleryCubit.close();
    });

    Widget createTestViewer({int initialIndex = 0}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: MaterialApp(
          home: PhotoViewerScreen(
            args: PhotoViewerArgs(
              photos: testPhotos,
              initialIndex: initialIndex,
            ),
            photoRepository: mockRepo,
          ),
        ),
      );
    }

    testWidgets('renders initial photo with index indicator and metadata', (
      tester,
    ) async {
      await tester.pumpWidget(createTestViewer(initialIndex: 0));
      await tester.pumpAndSettle();

      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('IMG_0001.JPG'), findsOneWidget);
      expect(find.textContaining('1920 × 1080'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets(
      'swiping PageView navigates to next photo and updates metadata',
      (tester) async {
        await tester.pumpWidget(createTestViewer(initialIndex: 0));
        await tester.pumpAndSettle();

        expect(find.text('1 of 3'), findsOneWidget);

        // Drag left to swipe to the next photo
        await tester.drag(find.byType(PageView), const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.text('2 of 3'), findsOneWidget);
        expect(find.text('IMG_0002.JPG'), findsOneWidget);
        expect(find.textContaining('3840 × 2160'), findsOneWidget);
      },
    );

    testWidgets('single tap on canvas toggles immersive overlay visibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestViewer(initialIndex: 0));
      await tester.pumpAndSettle();

      // Initially overlay is visible (ignorePointer is false, opacity 1.0)
      final initialOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(initialOpacity.opacity, equals(1.0));

      // Tap on the image canvas
      await tester.tap(find.byType(InteractiveViewer));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Overlay should now be hidden (opacity 0.0)
      final hiddenOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(hiddenOpacity.opacity, equals(0.0));

      // Tap again to restore overlay
      await tester.tap(find.byType(InteractiveViewer));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      final restoredOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(restoredOpacity.opacity, equals(1.0));
    });

    testWidgets('favorite action toggles photo favorite state', (tester) async {
      await galleryCubit.loadInitialPhotos();
      await tester.pumpWidget(createTestViewer(initialIndex: 0));
      await tester.pumpAndSettle();

      // Find favorite button (Icons.favorite_border initially)
      final favButton = find.byTooltip('Favorite');
      expect(favButton, findsOneWidget);

      await tester.tap(favButton);
      await tester.pumpAndSettle();

      // Now should have unfavorite tooltip
      expect(find.byTooltip('Unfavorite'), findsOneWidget);
    });

    testWidgets(
      'delete action shows confirmation dialog and cancels without removing',
      (tester) async {
        await tester.pumpWidget(createTestViewer(initialIndex: 0));
        await tester.pumpAndSettle();

        // Tap delete icon
        final deleteButton = find.byTooltip('Delete');
        expect(deleteButton, findsOneWidget);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Confirmation dialog appears
        expect(find.text('Delete Photo'), findsOneWidget);
        expect(
          find.text(
            'Are you sure you want to remove this photo from your gallery?',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);

        // Cancel dismissal
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog dismissed, still 1 of 3
        expect(find.text('Delete Photo'), findsNothing);
        expect(find.text('1 of 3'), findsOneWidget);
      },
    );

    testWidgets(
      'delete action confirmed removes photo and updates page counter',
      (tester) async {
        await galleryCubit.loadInitialPhotos();
        await tester.pumpWidget(createTestViewer(initialIndex: 0));
        await tester.pumpAndSettle();

        expect(find.text('1 of 3'), findsOneWidget);

        // Tap delete
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();

        // Tap Delete in dialog
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        // Photo removed, counter updates to 1 of 2
        expect(find.text('1 of 2'), findsOneWidget);
      },
    );
  });
}
