import 'dart:typed_data';

import 'photo_model.dart';

/// Device photo permission statuses.
enum DevicePermissionStatus { granted, limited, denied, restricted }

/// Abstract contract for device media and photo library access.
/// Decouples BLoCs and UI widgets from underlying plugins or native platforms.
abstract class PhotoRepository {
  /// Verifies current permission status without prompting user.
  Future<DevicePermissionStatus> checkPermission();

  /// Prompts user for photo library permissions if not already granted.
  Future<DevicePermissionStatus> requestPermission();

  /// Retrieves a paginated list of local device photos.
  Future<List<PhotoModel>> getPhotos({int page = 0, int pageSize = 40});

  /// Retrieves a memory-efficient thumbnail byte buffer for a photo.
  /// Enforces low-resolution retrieval to prevent OOM conditions in grids.
  Future<Uint8List?> getThumbnail(
    String photoId, {
    int width = 250,
    int height = 250,
  });

  /// Navigates the user directly to system application settings.
  Future<void> openAppSettings();

  /// Retrieves a high-resolution preview byte buffer for full-screen inspection.
  /// Bounded to a maximum dimension to safeguard memory.
  Future<Uint8List?> getFullPhoto(
    String photoId, {
    int maxWidth = 2048,
    int maxHeight = 2048,
  });

  /// Toggles favorite status on a photo asset.
  Future<bool> toggleFavorite(PhotoModel photo);

  /// Deletes a photo asset from the repository.
  Future<bool> deletePhoto(PhotoModel photo);
}
