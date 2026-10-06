import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';

void main() {
  group('GalleryScreen UI State Rendering', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() async {
      await themeCubit.close();
    });

    Widget createGalleryScreenTestApp({
      required GalleryCubit galleryCubit,
      VoidCallback? onOpenSettings,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
        ],
        child: MaterialApp(home: GalleryScreen(onOpenSettings: onOpenSettings)),
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
          createGalleryScreenTestApp(
            galleryCubit: cubit,
            onOpenSettings: () {
              settingsTapped = true;
            },
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('Photo Access Required'), findsOneWidget);
        expect(find.text('Open Device Settings'), findsOneWidget);

        await tester.tap(find.text('Open Device Settings'));
        await tester.pump();

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

      await tester.pumpWidget(createGalleryScreenTestApp(galleryCubit: cubit));
      await tester.pump();
      await tester.pump();

      expect(find.text('No Photos Found'), findsOneWidget);
      expect(find.text('Refresh Library'), findsOneWidget);

      await cubit.close();
    });

    testWidgets(
      'renders responsive grid with PhotoThumbnailTiles when loaded',
      (tester) async {
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

        await tester.pumpWidget(
          createGalleryScreenTestApp(galleryCubit: cubit),
        );
        await tester.pump();
        await tester.pump();

        expect(find.byType(PhotoThumbnailTile), findsWidgets);
        expect(find.text('Photos'), findsOneWidget);

        await cubit.close();
      },
    );
  });
}
