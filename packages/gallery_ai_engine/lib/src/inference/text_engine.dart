import 'dart:math' as math;
import '../preprocessing/clip_tokenizer.dart';
import 'vision_engine.dart';

/// On-Device Text Embedding Engine using MobileCLIP-S2 Text ONNX model.
/// Input: [1, 77] Int64 token tensor
/// Output: 512-D L2-normalized Float vector
class TextEngine {
  final OnnxTensorRunner runner;
  final ClipTokenizer tokenizer;

  TextEngine({
    required this.runner,
    ClipTokenizer? tokenizer,
  }) : tokenizer = tokenizer ?? ClipTokenizer();

  /// Converts a search query into a 512-D normalized vector for cosine search.
  Future<List<double>> embedQuery(String queryText) async {
    final tokens = tokenizer.tokenize(queryText);

    final rawOutputs = await runner(
      'text_model.onnx',
      tokens,
      [1, ClipTokenizer.contextLength],
    );

    if (rawOutputs.length != 512) {
      throw StateError(
          'Text model returned ${rawOutputs.length} elements, expected 512.');
    }

    return normalizeL2(rawOutputs);
  }

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
