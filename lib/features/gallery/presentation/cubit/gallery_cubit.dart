import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/category_model.dart';
import '../../domain/photo_model.dart';
import '../../domain/photo_repository.dart';
import 'gallery_state.dart';

/// Cubit orchestrating permission requests, category filtering, initial loading,
/// pagination, and responsive state updates for device photo access.
class GalleryCubit extends Cubit<GalleryState> {
  final PhotoRepository photoRepository;
  static const int pageSize = 40;

  GalleryCubit({required this.photoRepository}) : super(const GalleryInitial());

  /// Checks permission and loads categories and initial photos.
  Future<void> loadInitialPhotos({bool requestIfDenied = true}) async {
    emit(const GalleryPermissionChecking());

    try {
      var status = await photoRepository.checkPermission();

      if (status == DevicePermissionStatus.denied && requestIfDenied) {
        status = await photoRepository.requestPermission();
      }

      if (status == DevicePermissionStatus.denied ||
          status == DevicePermissionStatus.restricted) {
        emit(const GalleryPermissionDenied());
        return;
      }

      final isLimited = status == DevicePermissionStatus.limited;
      emit(const GalleryLoading());

      final categories = await photoRepository.getCategories();
      final defaultCategory = categories.isNotEmpty
          ? categories.first
          : const CategoryModel(
              id: 'all',
              title: 'All Photos',
              type: CategoryType.all,
            );

      final initialPhotos = await photoRepository.getPhotos(
        categoryId: defaultCategory.id,
        page: 0,
        pageSize: pageSize,
      );

      if (initialPhotos.isEmpty) {
        emit(
          GalleryEmpty(
            isLimitedPermission: isLimited,
            categories: categories,
            selectedCategory: defaultCategory,
          ),
        );
      } else {
        emit(
          GalleryLoaded(
            photos: initialPhotos,
            hasMore: initialPhotos.length >= pageSize,
            currentPage: 0,
            isLimitedPermission: isLimited,
            categories: categories,
            selectedCategory: defaultCategory,
          ),
        );
      }
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  /// Selects a category/album filter and loads its photos.
  Future<void> selectCategory(CategoryModel category) async {
    final currentState = state;
    List<CategoryModel> categories = [];
    bool isLimited = false;

    if (currentState is GalleryLoaded) {
      if (currentState.selectedCategory.id == category.id) return;
      categories = currentState.categories;
      isLimited = currentState.isLimitedPermission;
    } else if (currentState is GalleryEmpty) {
      if (currentState.selectedCategory?.id == category.id) return;
      categories = currentState.categories;
      isLimited = currentState.isLimitedPermission;
    }

    emit(const GalleryLoading());

    try {
      final photos = await photoRepository.getPhotos(
        categoryId: category.id,
        page: 0,
        pageSize: pageSize,
      );

      if (photos.isEmpty) {
        emit(
          GalleryEmpty(
            isLimitedPermission: isLimited,
            categories: categories,
            selectedCategory: category,
          ),
        );
      } else {
        emit(
          GalleryLoaded(
            photos: photos,
            hasMore: photos.length >= pageSize,
            currentPage: 0,
            isLimitedPermission: isLimited,
            categories: categories,
            selectedCategory: category,
          ),
        );
      }
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  /// Fetches the subsequent page of thumbnails and appends to the active list.
  Future<void> loadMorePhotos() async {
    final currentState = state;
    if (currentState is! GalleryLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newPhotos = await photoRepository.getPhotos(
        categoryId: currentState.selectedCategory.id,
        page: nextPage,
        pageSize: pageSize,
      );

      emit(
        currentState.copyWith(
          photos: [...currentState.photos, ...newPhotos],
          currentPage: nextPage,
          hasMore: newPhotos.length >= pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Reloads page 0 while preserving or re-evaluating permission.
  Future<void> refreshPhotos() async {
    await loadInitialPhotos(requestIfDenied: false);
  }

  /// Launches device application settings.
  Future<void> openAppSettings() async {
    await photoRepository.openAppSettings();
  }

  /// Toggles favorite status on a photo and updates the loaded collection and category badges.
  Future<void> toggleFavorite(PhotoModel photo) async {
    final currentState = state;
    if (currentState is! GalleryLoaded) return;

    final updatedPhoto = photo.copyWith(isFavorite: !photo.isFavorite);

    // If currently filtered by Favorites and photo was unfavorited, remove it from view
    List<PhotoModel> updatedList;
    if (currentState.selectedCategory.type == CategoryType.favorites &&
        !updatedPhoto.isFavorite) {
      updatedList = currentState.photos.where((p) => p.id != photo.id).toList();
    } else {
      updatedList = currentState.photos.map((p) {
        return p.id == photo.id ? updatedPhoto : p;
      }).toList();
    }

    // Update categories favorite count
    final updatedCategories = currentState.categories.map((c) {
      if (c.type == CategoryType.favorites) {
        final newCount = updatedPhoto.isFavorite
            ? c.photoCount + 1
            : (c.photoCount - 1).clamp(0, 999999);
        return c.copyWith(photoCount: newCount);
      }
      return c;
    }).toList();

    if (updatedList.isEmpty) {
      emit(
        GalleryEmpty(
          isLimitedPermission: currentState.isLimitedPermission,
          categories: updatedCategories,
          selectedCategory: currentState.selectedCategory,
        ),
      );
    } else {
      emit(
        currentState.copyWith(
          photos: updatedList,
          categories: updatedCategories,
        ),
      );
    }

    try {
      await photoRepository.toggleFavorite(photo);
    } catch (_) {
      // Revert if repository operation fails
      emit(currentState);
    }
  }

  /// Removes a photo from the active collection (e.g. after deletion).
  Future<void> removePhoto(String photoId) async {
    final currentState = state;
    if (currentState is! GalleryLoaded) return;

    final targetPhoto = currentState.photos.firstWhere(
      (p) => p.id == photoId,
      orElse: () => PhotoModel(
        id: photoId,
        width: 0,
        height: 0,
        createDateTime: DateTime.now(),
      ),
    );

    final updatedList = currentState.photos
        .where((p) => p.id != photoId)
        .toList();

    // Decrement counts in categories
    final updatedCategories = currentState.categories.map((c) {
      if (c.type == CategoryType.all ||
          (c.type == CategoryType.favorites && targetPhoto.isFavorite)) {
        return c.copyWith(photoCount: (c.photoCount - 1).clamp(0, 999999));
      }
      return c;
    }).toList();

    if (updatedList.isEmpty) {
      emit(
        GalleryEmpty(
          isLimitedPermission: currentState.isLimitedPermission,
          categories: updatedCategories,
          selectedCategory: currentState.selectedCategory,
        ),
      );
    } else {
      emit(
        currentState.copyWith(
          photos: updatedList,
          categories: updatedCategories,
        ),
      );
    }

    try {
      await photoRepository.deletePhoto(targetPhoto);
    } catch (_) {}
  }
}
