import 'dart:typed_data';

import '../domain/category_model.dart';
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
  Future<List<CategoryModel>> getCategories() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final favCount = _photos.where((p) => p.isFavorite).length;
    final screenshotCount = _photos
        .where((p) => (p.title ?? '').toLowerCase().contains('screenshot'))
        .length;
    final cameraCount = _photos
        .where((p) => (p.title ?? '').toLowerCase().contains('img'))
        .length;

    return [
      CategoryModel(
        id: 'all',
        title: 'All Photos',
        type: CategoryType.all,
        photoCount: _photos.length,
        coverPhotoId: _photos.isNotEmpty ? _photos.first.id : null,
      ),
      CategoryModel(
        id: 'favorites',
        title: 'Favorites',
        type: CategoryType.favorites,
        photoCount: favCount,
        coverPhotoId: _photos.any((p) => p.isFavorite)
            ? _photos.firstWhere((p) => p.isFavorite).id
            : null,
      ),
      CategoryModel(
        id: 'recent',
        title: 'Recent',
        type: CategoryType.recent,
        photoCount: _photos.length,
        coverPhotoId: _photos.isNotEmpty ? _photos.first.id : null,
      ),
      CategoryModel(
        id: 'screenshots',
        title: 'Screenshots',
        type: CategoryType.screenshots,
        photoCount: screenshotCount,
        coverPhotoId:
            _photos.any(
              (p) => (p.title ?? '').toLowerCase().contains('screenshot'),
            )
            ? _photos
                  .firstWhere(
                    (p) => (p.title ?? '').toLowerCase().contains('screenshot'),
                  )
                  .id
            : null,
      ),
      CategoryModel(
        id: 'camera',
        title: 'Camera',
        type: CategoryType.camera,
        photoCount: cameraCount,
        coverPhotoId:
            _photos.any((p) => (p.title ?? '').toLowerCase().contains('img'))
            ? _photos
                  .firstWhere(
                    (p) => (p.title ?? '').toLowerCase().contains('img'),
                  )
                  .id
            : null,
      ),
    ];
  }

  @override
  Future<List<PhotoModel>> getPhotos({
    String? categoryId,
    int page = 0,
    int pageSize = 40,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (permissionStatus != DevicePermissionStatus.granted &&
        permissionStatus != DevicePermissionStatus.limited) {
      return [];
    }

    List<PhotoModel> targetList;
    if (categoryId == 'favorites') {
      targetList = _photos.where((p) => p.isFavorite).toList();
    } else if (categoryId == 'screenshots') {
      targetList = _photos
          .where((p) => (p.title ?? '').toLowerCase().contains('screenshot'))
          .toList();
    } else if (categoryId == 'camera') {
      targetList = _photos
          .where((p) => (p.title ?? '').toLowerCase().contains('img'))
          .toList();
    } else if (categoryId == 'recent') {
      targetList = List.of(_photos)
        ..sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    } else {
      targetList = _photos;
    }

    final startIndex = page * pageSize;
    if (startIndex >= targetList.length) {
      return [];
    }

    final endIndex = (startIndex + pageSize).clamp(0, targetList.length);
    return targetList.sublist(startIndex, endIndex);
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
