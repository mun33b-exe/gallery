import 'dart:math' as math;

/// Fast vector math operations for 512-D MobileCLIP embeddings in pure Dart.
class VectorMath {
  /// Computes cosine similarity between two vectors.
  /// If both vectors are already L2 normalized, this is equivalent to dot product.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError(
          'Vector lengths must match: ${a.length} vs ${b.length}');
    }

    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      final double va = a[i];
      final double vb = b[i];
      dot += va * vb;
      normA += va * va;
      normB += vb * vb;
    }

    if (normA < 1e-12 || normB < 1e-12) return 0.0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  /// Dot product between two L2-normalized vectors (faster, avoids square roots).
  static double dotProductNormalized(List<double> a, List<double> b) {
    double dot = 0.0;
    final int len = a.length;
    for (int i = 0; i < len; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  /// Ranks items by cosine similarity to a query vector and returns the top K indices.
  static List<RankedItem<T>> topK<T>({
    required List<double> queryVector,
    required List<T> items,
    required List<double> Function(T item) vectorExtractor,
    int k = 20,
    double minThreshold = 0.15,
  }) {
    final List<RankedItem<T>> scored = [];

    for (final item in items) {
      final vec = vectorExtractor(item);
      final score = cosineSimilarity(queryVector, vec);
      if (score >= minThreshold) {
        scored.add(RankedItem(item: item, score: score));
      }
    }

    // Sort descending by score
    scored.sort((a, b) => b.score.compareTo(a.score));

    if (scored.length > k) {
      return scored.sublist(0, k);
    }
    return scored;
  }
}

class RankedItem<T> {
  final T item;
  final double score;

  RankedItem({required this.item, required this.score});
}
