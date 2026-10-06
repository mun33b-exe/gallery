import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/photo_repository.dart';
import 'gallery_state.dart';

/// Cubit orchestrating permission requests, initial loading, pagination,
/// and responsive state updates for device photo access.
class GalleryCubit extends Cubit<GalleryState> {
  final PhotoRepository photoRepository;
  static const int pageSize = 40;

  GalleryCubit({required this.photoRepository}) : super(const GalleryInitial());

  /// Checks permission and loads the initial page of photos.
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

      final initialPhotos = await photoRepository.getPhotos(
        page: 0,
        pageSize: pageSize,
      );

      if (initialPhotos.isEmpty) {
        emit(GalleryEmpty(isLimitedPermission: isLimited));
      } else {
        emit(
          GalleryLoaded(
            photos: initialPhotos,
            hasMore: initialPhotos.length >= pageSize,
            currentPage: 0,
            isLimitedPermission: isLimited,
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
}
