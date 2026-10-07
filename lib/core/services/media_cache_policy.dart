import 'package:flutter/painting.dart';

/// Policy manager for global image cache budgets, sizing bounds, and eviction.
/// Protects the application against Out-Of-Memory (OOM) crashes during rapid gallery scrolling.
class MediaCachePolicy {
  MediaCachePolicy._();

  /// Default maximum number of decoded images retained in cache.
  static const int kDefaultMaxImages = 200;

  /// Default maximum total size in bytes retained in memory (100MB).
  static const int kDefaultMaxSizeBytes = 100 * 1024 * 1024;

  /// Configures global PaintingBinding imageCache bounds.
  static void configure({
    int maxImages = kDefaultMaxImages,
    int maxSizeBytes = kDefaultMaxSizeBytes,
  }) {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = maxImages;
    cache.maximumSizeBytes = maxSizeBytes;
  }

  /// Clears active decoded memory cache and live image references.
  static void clear() {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  /// Current number of retained images in cache.
  static int get currentCount =>
      PaintingBinding.instance.imageCache.currentSize;

  /// Current estimated byte size of retained images in cache.
  static int get currentSizeBytes =>
      PaintingBinding.instance.imageCache.currentSizeBytes;

  /// Configured maximum image count.
  static int get maxImages => PaintingBinding.instance.imageCache.maximumSize;

  /// Configured maximum memory size in bytes.
  static int get maxSizeBytes =>
      PaintingBinding.instance.imageCache.maximumSizeBytes;
}
