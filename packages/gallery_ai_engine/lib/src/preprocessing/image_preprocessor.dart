import 'dart:typed_data';

/// Image preprocessing specifically tuned for Apple MobileCLIP-S2 ONNX model.
/// Output shape: [1, 3, 256, 256] (batch, channels, height, width).
class ImagePreprocessor {
  static const int targetWidth = 256;
  static const int targetHeight = 256;
  static const int targetChannels = 3;

  // Standard CLIP / MobileCLIP Normalization constants
  static const List<double> mean = [0.48145466, 0.4578275, 0.40821073];
  static const List<double> std = [0.26862954, 0.26130258, 0.27577711];

  /// Preprocesses raw RGB/RGBA byte buffer into Float32List CHW tensor [1, 3, 256, 256].
  ///
  /// [bytes]: Raw decoded pixel bytes (RGBA or RGB).
  /// [width]: Original image width.
  /// [height]: Original image height.
  /// [hasAlpha]: True if input is RGBA (4 bytes per pixel), false if RGB (3 bytes per pixel).
  static Float32List preprocessPixelBuffer({
    required Uint8List bytes,
    required int width,
    required int height,
    bool hasAlpha = true,
  }) {
    final int pixelStride = hasAlpha ? 4 : 3;
    final int totalElements = targetChannels * targetHeight * targetWidth;
    final Float32List outputTensor = Float32List(totalElements);

    final double scaleX = width / targetWidth;
    final double scaleY = height / targetHeight;

    // Plane offsets for Channel-First (CHW) layout
    final int rPlaneOffset = 0;
    final int gPlaneOffset = targetHeight * targetWidth;
    final int bPlaneOffset = 2 * targetHeight * targetWidth;

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        // Nearest-neighbor / Bilinear sampling
        final int srcX = (x * scaleX).floor().clamp(0, width - 1);
        final int srcY = (y * scaleY).floor().clamp(0, height - 1);
        final int srcIndex = (srcY * width + srcX) * pixelStride;

        final double r = bytes[srcIndex] / 255.0;
        final double g = bytes[srcIndex + 1] / 255.0;
        final double b = bytes[srcIndex + 2] / 255.0;

        // Apply CLIP Normalization
        final double rNorm = (r - mean[0]) / std[0];
        final double gNorm = (g - mean[1]) / std[1];
        final double bNorm = (b - mean[2]) / std[2];

        final int pixelIndex = y * targetWidth + x;

        outputTensor[rPlaneOffset + pixelIndex] = rNorm;
        outputTensor[gPlaneOffset + pixelIndex] = gNorm;
        outputTensor[bPlaneOffset + pixelIndex] = bNorm;
      }
    }

    return outputTensor;
  }

  /// Helper to convert simple RGB list [R, G, B, R, G, B...] already at 256x256 into CHW tensor.
  static Float32List fromRgb256x256(Uint8List rgbBytes) {
    const int planeSize = targetHeight * targetWidth;
    final Float32List tensor = Float32List(targetChannels * planeSize);

    for (int i = 0; i < planeSize; i++) {
      final double r = rgbBytes[i * 3] / 255.0;
      final double g = rgbBytes[i * 3 + 1] / 255.0;
      final double b = rgbBytes[i * 3 + 2] / 255.0;

      tensor[i] = (r - mean[0]) / std[0];
      tensor[planeSize + i] = (g - mean[1]) / std[1];
      tensor[2 * planeSize + i] = (b - mean[2]) / std[2];
    }

    return tensor;
  }
}
