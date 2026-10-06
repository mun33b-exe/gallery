import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';

void main() {
  group('PhotoViewerScreen Adaptive Design (Rule 5.3)', () {
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
      ];

      mockRepo = MockPhotoRepository(photos: testPhotos);
      galleryCubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await galleryCubit.close();
    });

    Widget createAdaptiveViewer({required TargetPlatform platform}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: platform),
          home: PhotoViewerScreen(
            args: PhotoViewerArgs(photos: testPhotos, initialIndex: 0),
            photoRepository: mockRepo,
          ),
        ),
      );
    }

    testWidgets(
      'iOS target renders Cupertino buttons, icons, and CupertinoAlertDialog',
      (tester) async {
        await tester.pumpWidget(
          createAdaptiveViewer(platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        // Top bar uses CupertinoButton on iOS
        expect(find.byType(CupertinoButton), findsWidgets);
        expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);

        // Tap delete to trigger dialog
        await tester.tap(find.byIcon(CupertinoIcons.trash));
        await tester.pumpAndSettle();

        // Renders native CupertinoAlertDialog and CupertinoDialogActions
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.byType(CupertinoDialogAction), findsNWidgets(2));
      },
    );

    testWidgets('iOS share action triggers CupertinoActionSheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        createAdaptiveViewer(platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.share));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Share Image'), findsOneWidget);
      expect(find.text('Save to Files'), findsOneWidget);
    });

    testWidgets(
      'Android target renders Material IconButtons and Material AlertDialog',
      (tester) async {
        await tester.pumpWidget(
          createAdaptiveViewer(platform: TargetPlatform.android),
        );
        await tester.pumpAndSettle();

        // Top bar uses IconButton on Android
        expect(find.byType(IconButton), findsWidgets);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.share_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);

        // Tap delete to trigger dialog
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Renders Material AlertDialog with TextButtons
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(2));
      },
    );

    testWidgets('Android share action triggers SnackBar', (tester) async {
      await tester.pumpWidget(
        createAdaptiveViewer(platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Sharing IMG_0001.JPG'), findsOneWidget);
    });
  });
}
