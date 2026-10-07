import 'dart:math' as math;
import 'dart:typed_data';

/// Interface for ONNX session execution to allow flexible integration with
/// `package:onnxruntime` or Flutter FFI bindings.
typedef OnnxTensorRunner = Future<List<double>> Function(
  String modelName,
  List<dynamic> inputValues,
  List<int> shape,
);

/// On-Device Vision Embedding Engine using MobileCLIP-S2 ONNX model.
/// Input: [1, 3, 256, 256] Float32List
/// Output: 512-D L2-normalized Float vector
class VisionEngine {
  final OnnxTensorRunner runner;

  VisionEngine({required this.runner});

  /// Runs inference and returns normalized 512-D embedding
  Future<List<double>> embedImage(Float32List preprocessedTensor) async {
    const int expectedLength = 1 * 3 * 256 * 256;
    if (preprocessedTensor.length != expectedLength) {
      throw ArgumentError(
        'Expected Float32List of length $expectedLength [1, 3, 256, 256], got: ${preprocessedTensor.length}',
      );
    }

    final rawOutputs = await runner(
      'vision_model.onnx',
      preprocessedTensor,
      [1, 3, 256, 256],
    );

    if (rawOutputs.length != 512) {
      throw StateError(
          'Vision model returned ${rawOutputs.length} elements, expected 512.');
    }

    // L2 Normalization
    return normalizeL2(rawOutputs);
  }

  /// Normalizes a vector to unit length (L2 norm)
  static List<double> normalizeL2(List<double> vector) {
    double sumSq = 0.0;
    for (int i = 0; i < vector.length; i++) {
      sumSq += vector[i] * vector[i];
    }
    final double norm = math.sqrt(sumSq);
    if (norm < 1e-12) return vector;

    final List<double> normalized = List<double>.filled(vector.length, 0.0);
    for (int i = 0; i < vector.length; i++) {
      normalized[i] = vector[i] / norm;
    }
    return normalized;
  }
}
