import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/category_model.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_state.dart';

void main() {
  group('Category Domain & Repository Tests', () {
    late List<PhotoModel> testPhotos;
    late MockPhotoRepository mockRepo;

    setUp(() {
      final now = DateTime.now();
      testPhotos = [
        PhotoModel(
          id: 'p1',
          title: 'IMG_001.JPG',
          width: 1920,
          height: 1080,
          createDateTime: now.subtract(const Duration(days: 1)),
          isFavorite: true,
        ),
        PhotoModel(
          id: 'p2',
          title: 'Screenshot_2024.PNG',
          width: 1080,
          height: 2400,
          createDateTime: now.subtract(const Duration(days: 2)),
          isFavorite: false,
        ),
        PhotoModel(
          id: 'p3',
          title: 'IMG_002.JPG',
          width: 1920,
          height: 1080,
          createDateTime: now.subtract(const Duration(days: 3)),
          isFavorite: false,
        ),
      ];
      mockRepo = MockPhotoRepository(photos: testPhotos);
    });

    test('CategoryModel equality and copyWith', () {
      const cat1 = CategoryModel(
        id: 'c1',
        title: 'Camera',
        type: CategoryType.camera,
        photoCount: 10,
      );
      const cat2 = CategoryModel(
        id: 'c1',
        title: 'Camera',
        type: CategoryType.camera,
        photoCount: 10,
      );
      final cat3 = cat1.copyWith(photoCount: 11);

      expect(cat1, equals(cat2));
      expect(cat1, isNot(equals(cat3)));
      expect(cat3.photoCount, equals(11));
    });

    test(
      'getCategories generates standard local albums with accurate counts',
      () async {
        final categories = await mockRepo.getCategories();

        expect(categories.length, equals(5));

        final allCat = categories.firstWhere((c) => c.type == CategoryType.all);
        final favCat = categories.firstWhere(
          (c) => c.type == CategoryType.favorites,
        );
        final screenshotCat = categories.firstWhere(
          (c) => c.type == CategoryType.screenshots,
        );
        final cameraCat = categories.firstWhere(
          (c) => c.type == CategoryType.camera,
        );

        expect(allCat.photoCount, equals(3));
        expect(favCat.photoCount, equals(1));
        expect(screenshotCat.photoCount, equals(1));
        expect(cameraCat.photoCount, equals(2));
      },
    );

    test('getPhotos filtered by categoryId returns matching subset', () async {
      final favPhotos = await mockRepo.getPhotos(categoryId: 'favorites');
      expect(favPhotos.length, equals(1));
      expect(favPhotos.first.id, equals('p1'));

      final screenshotPhotos = await mockRepo.getPhotos(
        categoryId: 'screenshots',
      );
      expect(screenshotPhotos.length, equals(1));
      expect(screenshotPhotos.first.id, equals('p2'));

      final cameraPhotos = await mockRepo.getPhotos(categoryId: 'camera');
      expect(cameraPhotos.length, equals(2));
      expect(cameraPhotos.map((p) => p.id), containsAll(['p1', 'p3']));
    });
  });

  group('GalleryCubit Category State Transitions', () {
    late List<PhotoModel> testPhotos;
    late MockPhotoRepository mockRepo;
    late GalleryCubit cubit;

    setUp(() {
      final now = DateTime.now();
      testPhotos = [
        PhotoModel(
          id: 'p1',
          title: 'IMG_001.JPG',
          width: 1920,
          height: 1080,
          createDateTime: now.subtract(const Duration(days: 1)),
          isFavorite: true,
        ),
        PhotoModel(
          id: 'p2',
          title: 'Screenshot_2024.PNG',
          width: 1080,
          height: 2400,
          createDateTime: now.subtract(const Duration(days: 2)),
          isFavorite: false,
        ),
      ];
      mockRepo = MockPhotoRepository(photos: testPhotos);
      cubit = GalleryCubit(photoRepository: mockRepo);
    });

    tearDown(() async {
      await cubit.close();
    });

    test(
      'initial loading populates categories and sets default category to all',
      () async {
        await cubit.loadInitialPhotos();

        expect(cubit.state, isA<GalleryLoaded>());
        final loaded = cubit.state as GalleryLoaded;
        expect(loaded.categories.isNotEmpty, isTrue);
        expect(loaded.selectedCategory.type, equals(CategoryType.all));
        expect(loaded.photos.length, equals(2));
      },
    );

    test(
      'selectCategory switches active photos and maintains categories list',
      () async {
        await cubit.loadInitialPhotos();
        final loaded = cubit.state as GalleryLoaded;
        final favCat = loaded.categories.firstWhere(
          (c) => c.type == CategoryType.favorites,
        );

        await cubit.selectCategory(favCat);

        final newLoaded = cubit.state as GalleryLoaded;
        expect(newLoaded.selectedCategory.type, equals(CategoryType.favorites));
        expect(newLoaded.photos.length, equals(1));
        expect(newLoaded.photos.first.id, equals('p1'));
      },
    );

    test('selecting an empty category emits GalleryEmpty with contextual category and categories list', () async {
      final noScreenshotsRepo = MockPhotoRepository(
        photos: [
          PhotoModel(
            id: 'p1',
            title: 'IMG_001.JPG',
            width: 100,
            height: 100,
            createDateTime: DateTime.now(),
          ),
        ],
      );
      final emptyCubit = GalleryCubit(photoRepository: noScreenshotsRepo);
      await emptyCubit.loadInitialPhotos();

      final categories = (emptyCubit.state as GalleryLoaded).categories;
      final screenshotCat = categories.firstWhere(
        (c) => c.type == CategoryType.screenshots,
      );

      await emptyCubit.selectCategory(screenshotCat);

      expect(emptyCubit.state, isA<GalleryEmpty>());
      final emptyState = emptyCubit.state as GalleryEmpty;
      expect(
        emptyState.selectedCategory?.type,
        equals(CategoryType.screenshots),
      );
      expect(emptyState.categories.isNotEmpty, isTrue);

      await emptyCubit.close();
    });

    test('unfavoriting a photo while in Favorites category removes it from view and updates badge', () async {
      await cubit.loadInitialPhotos();
      final categories = (cubit.state as GalleryLoaded).categories;
      final favCat = categories.firstWhere(
        (c) => c.type == CategoryType.favorites,
      );

      await cubit.selectCategory(favCat);
      expect((cubit.state as GalleryLoaded).photos.length, equals(1));

      // Unfavorite p1
      await cubit.toggleFavorite(testPhotos.first);

      // Collection is now empty in Favorites
      expect(cubit.state, isA<GalleryEmpty>());
      final emptyState = cubit.state as GalleryEmpty;
      expect(emptyState.selectedCategory?.type, equals(CategoryType.favorites));

      final updatedFavCat = emptyState.categories.firstWhere(
        (c) => c.type == CategoryType.favorites,
      );
      expect(updatedFavCat.photoCount, equals(0));
    });
  });
}
