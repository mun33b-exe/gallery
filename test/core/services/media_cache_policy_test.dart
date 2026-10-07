import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/core/services/media_cache_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaCachePolicy Unit Tests', () {
    setUp(() {
      MediaCachePolicy.clear();
    });

    tearDown(() {
      MediaCachePolicy.configure();
      MediaCachePolicy.clear();
    });

    test('configures custom image cache budget and limits', () {
      MediaCachePolicy.configure(
        maxImages: 150,
        maxSizeBytes: 50 * 1024 * 1024,
      );

      expect(MediaCachePolicy.maxImages, 150);
      expect(MediaCachePolicy.maxSizeBytes, 50 * 1024 * 1024);
      expect(PaintingBinding.instance.imageCache.maximumSize, 150);
      expect(
        PaintingBinding.instance.imageCache.maximumSizeBytes,
        50 * 1024 * 1024,
      );
    });

    test('default configuration sets 200 images and 100MB bound', () {
      MediaCachePolicy.configure();

      expect(MediaCachePolicy.maxImages, MediaCachePolicy.kDefaultMaxImages);
      expect(
        MediaCachePolicy.maxSizeBytes,
        MediaCachePolicy.kDefaultMaxSizeBytes,
      );
    });

    test('clear resets live and cached image collections', () {
      MediaCachePolicy.clear();
      expect(MediaCachePolicy.currentCount, 0);
      expect(MediaCachePolicy.currentSizeBytes, 0);
    });
  });
}
