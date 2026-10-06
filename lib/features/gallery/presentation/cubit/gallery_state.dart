import 'package:equatable/equatable.dart';

import '../../domain/category_model.dart';
import '../../domain/photo_model.dart';

/// Base state for Gallery.
abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class GalleryInitial extends GalleryState {
  const GalleryInitial();
}

/// Checking or requesting photo library permissions.
class GalleryPermissionChecking extends GalleryState {
  const GalleryPermissionChecking();
}

/// User has explicitly denied photo permissions or restricted access.
class GalleryPermissionDenied extends GalleryState {
  const GalleryPermissionDenied();
}

/// Initial loading of photos page 0.
class GalleryLoading extends GalleryState {
  const GalleryLoading();
}

/// Gallery loaded with photos, categories, and pagination metadata.
class GalleryLoaded extends GalleryState {
  final List<PhotoModel> photos;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isLimitedPermission;
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;

  const GalleryLoaded({
    required this.photos,
    required this.hasMore,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.isLimitedPermission = false,
    this.categories = const [],
    required this.selectedCategory,
  });

  GalleryLoaded copyWith({
    List<PhotoModel>? photos,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isLimitedPermission,
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
  }) {
    return GalleryLoaded(
      photos: photos ?? this.photos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLimitedPermission: isLimitedPermission ?? this.isLimitedPermission,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    photos,
    hasMore,
    currentPage,
    isLoadingMore,
    isLimitedPermission,
    categories,
    selectedCategory,
  ];
}

/// Permission was granted, but no photos were found in the library or active category.
class GalleryEmpty extends GalleryState {
  final bool isLimitedPermission;
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;

  const GalleryEmpty({
    this.isLimitedPermission = false,
    this.categories = const [],
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [
    isLimitedPermission,
    categories,
    selectedCategory,
  ];
}

/// An error occurred while accessing the photo library.
class GalleryError extends GalleryState {
  final String message;

  const GalleryError({required this.message});

  @override
  List<Object?> get props => [message];
}
