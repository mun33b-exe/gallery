import 'package:equatable/equatable.dart';

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

/// Gallery loaded with photos and pagination metadata.
class GalleryLoaded extends GalleryState {
  final List<PhotoModel> photos;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isLimitedPermission;

  const GalleryLoaded({
    required this.photos,
    required this.hasMore,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.isLimitedPermission = false,
  });

  GalleryLoaded copyWith({
    List<PhotoModel>? photos,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isLimitedPermission,
  }) {
    return GalleryLoaded(
      photos: photos ?? this.photos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLimitedPermission: isLimitedPermission ?? this.isLimitedPermission,
    );
  }

  @override
  List<Object?> get props => [
    photos,
    hasMore,
    currentPage,
    isLoadingMore,
    isLimitedPermission,
  ];
}

/// Permission was granted, but no photos were found in the library.
class GalleryEmpty extends GalleryState {
  final bool isLimitedPermission;

  const GalleryEmpty({this.isLimitedPermission = false});

  @override
  List<Object?> get props => [isLimitedPermission];
}

/// An error occurred while accessing the photo library.
class GalleryError extends GalleryState {
  final String message;

  const GalleryError({required this.message});

  @override
  List<Object?> get props => [message];
}
