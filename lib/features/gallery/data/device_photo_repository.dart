import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../domain/photo_model.dart';
import '../domain/photo_repository.dart';

/// Real device implementation of [PhotoRepository] using `photo_manager`.
/// Guarantees that only low-resolution thumbnails are loaded in grid previews.
class DevicePhotoRepository implements PhotoRepository {
  List<AssetPathEntity>? _cachedPaths;

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
  Future<List<PhotoModel>> getPhotos({int page = 0, int pageSize = 40}) async {
    final permission = await checkPermission();
    if (permission != DevicePermissionStatus.granted &&
        permission != DevicePermissionStatus.limited) {
      return [];
    }

    _cachedPaths ??= await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (_cachedPaths!.isEmpty) {
      return [];
    }

    final recentAlbum = _cachedPaths!.first;
    final assets = await recentAlbum.getAssetListPaged(
      page: page,
      size: pageSize,
    );

    return assets.map(_mapAssetToPhotoModel).toList();
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
