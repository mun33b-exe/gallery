import 'dart:convert';
import 'dart:math' as math;
import '../models/pipeline_result.dart';

/// Lightning-fast on-device Linear Head Classifier.
/// Evaluates the 512-D MobileCLIP image embedding in < 0.1ms using pure Dart matrix math.
class ClassifierHead {
  List<List<double>>? _weights; // Shape: [3, 512]
  List<double>? _bias; // Shape: [3]

  bool get isLoaded => _weights != null && _bias != null;

  /// Load weights from the exported weights.json content.
  void loadWeightsFromJson(String jsonContent) {
    final Map<String, dynamic> data = jsonDecode(jsonContent);

    final List<dynamic> rawWeight = data['weight'];
    _weights = rawWeight
        .map((row) =>
            (row as List<dynamic>).map((e) => (e as num).toDouble()).toList())
        .toList();

    final List<dynamic> rawBias = data['bias'];
    _bias = rawBias.map((e) => (e as num).toDouble()).toList();
  }

  /// Direct setter if weights are bundled as pre-parsed structures
  void setWeights(List<List<double>> weights, List<double> bias) {
    if (weights.length != 3 || bias.length != 3) {
      throw ArgumentError(
          'Classifier head expects 3 output classes (Photo, Doc, Uncertain).');
    }
    _weights = weights;
    _bias = bias;
  }

  /// Classifies a 512-D MobileCLIP embedding vector.
  ClassificationResult classify(List<double> embedding512) {
    if (!isLoaded) {
      throw StateError(
          'ClassifierHead weights have not been loaded. Call loadWeightsFromJson() first.');
    }

    if (embedding512.length != 512) {
      throw ArgumentError(
          'Expected 512-D embedding vector, received length: ${embedding512.length}');
    }

    final weights = _weights!;
    final bias = _bias!;
    final List<double> logits = List.filled(3, 0.0);

    // Matrix Multiplication: logits = (W * v) + b
    for (int i = 0; i < 3; i++) {
      double dot = 0.0;
      final row = weights[i];
      for (int j = 0; j < 512; j++) {
        dot += embedding512[j] * row[j];
      }
      logits[i] = dot + bias[i];
    }

    // Softmax probabilities
    final maxLogit = logits.reduce(math.max);
    final expList = logits.map((l) => math.exp(l - maxLogit)).toList();
    final expSum = expList.reduce((a, b) => a + b);
    final probabilities = expList.map((e) => e / expSum).toList();

    // ArgMax
    int maxIndex = 0;
    for (int i = 1; i < 3; i++) {
      if (logits[i] > logits[maxIndex]) {
        maxIndex = i;
      }
    }

    final label = ImageClassification.fromIndex(maxIndex);
    final confidence = probabilities[maxIndex];

    return ClassificationResult(
      label: label,
      logits: logits,
      probabilities: probabilities,
      confidence: confidence,
    );
  }
}
