import 'dart:typed_data';

import '../domain/photo_model.dart';
import '../domain/photo_repository.dart';

/// In-memory mock implementation of [PhotoRepository] for testing and headless CI.
class MockPhotoRepository implements PhotoRepository {
  DevicePermissionStatus permissionStatus;
  final Duration simulatedDelay;
  final List<PhotoModel> _photos;
  bool appSettingsOpened = false;

  // Minimal 1x1 transparent PNG valid byte sequence
  static final Uint8List kMockThumbnailBytes = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  MockPhotoRepository({
    this.permissionStatus = DevicePermissionStatus.granted,
    this.simulatedDelay = Duration.zero,
    List<PhotoModel>? photos,
  }) : _photos = photos ?? _generateMockPhotos(count: 65);

  static List<PhotoModel> _generateMockPhotos({int count = 65}) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      return PhotoModel(
        id: 'mock_photo_$index',
        title: 'IMG_${20240000 + index}.JPG',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(Duration(hours: index * 6)),
        isFavorite: index % 5 == 0,
        mimeType: 'image/jpeg',
      );
    });
  }

  @override
  Future<DevicePermissionStatus> checkPermission() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return permissionStatus;
  }

  @override
  Future<DevicePermissionStatus> requestPermission() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return permissionStatus;
  }

  @override
  Future<List<PhotoModel>> getPhotos({int page = 0, int pageSize = 40}) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (permissionStatus != DevicePermissionStatus.granted &&
        permissionStatus != DevicePermissionStatus.limited) {
      return [];
    }

    final startIndex = page * pageSize;
    if (startIndex >= _photos.length) {
      return [];
    }

    final endIndex = (startIndex + pageSize).clamp(0, _photos.length);
    return _photos.sublist(startIndex, endIndex);
  }

  @override
  Future<Uint8List?> getThumbnail(
    String photoId, {
    int width = 250,
    int height = 250,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return kMockThumbnailBytes;
  }

  @override
  Future<void> openAppSettings() async {
    appSettingsOpened = true;
  }

  @override
  Future<Uint8List?> getFullPhoto(
    String photoId, {
    int maxWidth = 2048,
    int maxHeight = 2048,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return kMockThumbnailBytes;
  }

  @override
  Future<bool> toggleFavorite(PhotoModel photo) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    final index = _photos.indexWhere((p) => p.id == photo.id);
    if (index != -1) {
      final updated = _photos[index].copyWith(
        isFavorite: !_photos[index].isFavorite,
      );
      _photos[index] = updated;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deletePhoto(PhotoModel photo) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    final initialLen = _photos.length;
    _photos.removeWhere((p) => p.id == photo.id);
    return _photos.length < initialLen;
  }
}
