import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_state.dart';

void main() {
  group('GalleryCubit State & Pagination Tests', () {
    late MockPhotoRepository mockRepo;
    late GalleryCubit galleryCubit;

    setUp(() {
      mockRepo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
      );
      galleryCubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await galleryCubit.close();
    });

    test('initial state is GalleryInitial', () {
      expect(galleryCubit.state, equals(const GalleryInitial()));
    });

    test(
      'loadInitialPhotos with granted permission loads first page (40 photos)',
      () async {
        await galleryCubit.loadInitialPhotos();

        expect(galleryCubit.state, isA<GalleryLoaded>());
        final loaded = galleryCubit.state as GalleryLoaded;
        expect(loaded.photos.length, equals(40));
        expect(loaded.hasMore, isTrue);
        expect(loaded.currentPage, equals(0));
        expect(loaded.isLimitedPermission, isFalse);
      },
    );

    test(
      'loadInitialPhotos with denied permission emits GalleryPermissionDenied',
      () async {
        final deniedRepo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.denied,
          simulatedDelay: Duration.zero,
        );
        final deniedCubit = GalleryCubit(photoRepository: deniedRepo);

        await deniedCubit.loadInitialPhotos();
        expect(deniedCubit.state, isA<GalleryPermissionDenied>());

        await deniedCubit.close();
      },
    );

    test(
      'loadInitialPhotos with limited permission marks isLimitedPermission',
      () async {
        final limitedRepo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.limited,
          simulatedDelay: Duration.zero,
        );
        final limitedCubit = GalleryCubit(photoRepository: limitedRepo);

        await limitedCubit.loadInitialPhotos();
        expect(limitedCubit.state, isA<GalleryLoaded>());
        final loaded = limitedCubit.state as GalleryLoaded;
        expect(loaded.isLimitedPermission, isTrue);

        await limitedCubit.close();
      },
    );

    test(
      'loadInitialPhotos emits GalleryEmpty when repository has zero photos',
      () async {
        final emptyRepo = MockPhotoRepository(
          permissionStatus: DevicePermissionStatus.granted,
          simulatedDelay: Duration.zero,
          photos: [],
        );
        final emptyCubit = GalleryCubit(photoRepository: emptyRepo);

        await emptyCubit.loadInitialPhotos();
        expect(emptyCubit.state, isA<GalleryEmpty>());

        await emptyCubit.close();
      },
    );

    test(
      'loadMorePhotos appends next page slice and updates hasMore',
      () async {
        // Repository has 65 photos total. Page 0 = 40 photos. Page 1 = remaining 25 photos.
        await galleryCubit.loadInitialPhotos();
        expect((galleryCubit.state as GalleryLoaded).photos.length, equals(40));

        await galleryCubit.loadMorePhotos();
        expect(galleryCubit.state, isA<GalleryLoaded>());
        final loaded = galleryCubit.state as GalleryLoaded;
        expect(loaded.photos.length, equals(65));
        expect(loaded.currentPage, equals(1));
        expect(loaded.hasMore, isFalse);
      },
    );

    test('loadMorePhotos ignores execution if hasMore is false', () async {
      final smallRepo = MockPhotoRepository(
        permissionStatus: DevicePermissionStatus.granted,
        simulatedDelay: Duration.zero,
        photos: List.generate(
          10,
          (i) => PhotoModel(
            id: '$i',
            width: 100,
            height: 100,
            createDateTime: DateTime.now(),
          ),
        ),
      );
      final smallCubit = GalleryCubit(photoRepository: smallRepo);

      await smallCubit.loadInitialPhotos();
      final loadedState = smallCubit.state as GalleryLoaded;
      expect(loadedState.hasMore, isFalse);
      expect(loadedState.photos.length, equals(10));

      // Attempt to load more
      await smallCubit.loadMorePhotos();
      expect((smallCubit.state as GalleryLoaded).photos.length, equals(10));

      await smallCubit.close();
    });

    test('openAppSettings delegates to repository', () async {
      expect(mockRepo.appSettingsOpened, isFalse);
      await galleryCubit.openAppSettings();
      expect(mockRepo.appSettingsOpened, isTrue);
    });
  });
}
