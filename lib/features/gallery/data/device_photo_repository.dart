import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../domain/category_model.dart';
import '../domain/photo_model.dart';
import '../domain/photo_repository.dart';

/// Real device implementation of [PhotoRepository] using `photo_manager`.
/// Guarantees that only low-resolution thumbnails are loaded in grid previews.
class DevicePhotoRepository implements PhotoRepository {
  @override
  Future<DevicePermissionStatus> checkPermission() async {
    final ps = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return _mapPermissionState(ps);
  }

  @override
  Future<DevicePermissionStatus> requestPermission() async {
    final ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(),
    );
    return _mapPermissionState(ps);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final permission = await checkPermission();
    if (permission != DevicePermissionStatus.granted &&
        permission != DevicePermissionStatus.limited) {
      return [];
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );

      final categories = <CategoryModel>[];
      for (final path in paths) {
        final count = await path.assetCountAsync;
        final name = path.name.toLowerCase();
        CategoryType type;
        if (path.isAll || name == 'recent' || name == 'recents') {
          type = CategoryType.all;
        } else if (name.contains('favorite')) {
          type = CategoryType.favorites;
        } else if (name.contains('screenshot')) {
          type = CategoryType.screenshots;
        } else if (name.contains('camera') || name.contains('dcim')) {
          type = CategoryType.camera;
        } else {
          type = CategoryType.recent;
        }

        if (count > 0 ||
            type == CategoryType.all ||
            type == CategoryType.favorites) {
          categories.add(
            CategoryModel(
              id: path.id,
              title: path.isAll ? 'All Photos' : path.name,
              type: type,
              photoCount: count,
            ),
          );
        }
      }

      if (categories.isEmpty) {
        categories.add(
          const CategoryModel(
            id: 'all',
            title: 'All Photos',
            type: CategoryType.all,
            photoCount: 0,
          ),
        );
      }

      return categories;
    } catch (_) {
      return const [
        CategoryModel(
          id: 'all',
          title: 'All Photos',
          type: CategoryType.all,
          photoCount: 0,
        ),
      ];
    }
  }

  @override
  Future<List<PhotoModel>> getPhotos({
    String? categoryId,
    int page = 0,
    int pageSize = 40,
  }) async {
    final permission = await checkPermission();
    if (permission != DevicePermissionStatus.granted &&
        permission != DevicePermissionStatus.limited) {
      return [];
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: categoryId == null || categoryId == 'all',
      );

      if (paths.isEmpty) {
        return [];
      }

      AssetPathEntity targetAlbum = paths.first;
      if (categoryId != null && categoryId != 'all') {
        targetAlbum = paths.firstWhere(
          (p) => p.id == categoryId,
          orElse: () => paths.first,
        );
      }

      final assets = await targetAlbum.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      return assets.map(_mapAssetToPhotoModel).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Uint8List?> getThumbnail(
    String photoId, {
    int width = 250,
    int height = 250,
  }) async {
    final asset = await AssetEntity.fromId(photoId);
    if (asset == null) return null;

    return asset.thumbnailDataWithSize(
      ThumbnailSize(width, height),
      quality: 85,
    );
  }

  @override
  Future<void> openAppSettings() async {
    await PhotoManager.openSetting();
  }

  @override
  Future<Uint8List?> getFullPhoto(
    String photoId, {
    int maxWidth = 2048,
    int maxHeight = 2048,
  }) async {
    final asset = await AssetEntity.fromId(photoId);
    if (asset == null) return null;

    return asset.thumbnailDataWithSize(
      ThumbnailSize(maxWidth, maxHeight),
      quality: 95,
    );
  }

  @override
  Future<bool> toggleFavorite(PhotoModel photo) async {
    final asset = await AssetEntity.fromId(photo.id);
    if (asset == null) return false;
    try {
      await PhotoManager.editor.darwin.favoriteAsset(
        entity: asset,
        favorite: !photo.isFavorite,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deletePhoto(PhotoModel photo) async {
    final asset = await AssetEntity.fromId(photo.id);
    if (asset == null) return false;
    try {
      final result = await PhotoManager.editor.deleteWithIds([photo.id]);
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  PhotoModel _mapAssetToPhotoModel(AssetEntity entity) {
    return PhotoModel(
      id: entity.id,
      title: entity.title,
      width: entity.width,
      height: entity.height,
      createDateTime: entity.createDateTime,
      isFavorite: entity.isFavorite,
      mimeType: entity.mimeType,
      orientation: entity.orientation,
    );
  }

  DevicePermissionStatus _mapPermissionState(PermissionState state) {
    switch (state) {
      case PermissionState.authorized:
        return DevicePermissionStatus.granted;
      case PermissionState.limited:
        return DevicePermissionStatus.limited;
      case PermissionState.restricted:
        return DevicePermissionStatus.restricted;
      case PermissionState.denied:
      case PermissionState.notDetermined:
        return DevicePermissionStatus.denied;
    }
  }
}
