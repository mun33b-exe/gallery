import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

/// Service managing the on-device ONNX runtime environment and model session.
class OnnxModelService {
  OrtSession? _textSession;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initializes the native OrtEnv and loads text_model.onnx session.
  Future<void> initialize({
    String assetPath = 'assets/models/text_model.onnx',
  }) async {
    if (_initialized) return;

    try {
      OrtEnv.instance.init();
      final byteData = await rootBundle.load(assetPath);
      final rawBytes = byteData.buffer.asUint8List();
      final sessionOptions = OrtSessionOptions();
      _textSession = OrtSession.fromBuffer(rawBytes, sessionOptions);
      _initialized = true;
    } catch (_) {
      // In headless test environments where native libraries are absent,
      // fail gracefully so test doubles can take over.
      _initialized = false;
    }
  }

  /// Runs the text encoder session with input token tensor [1, 77].
  Future<List<double>> runTextModel(
    String modelName,
    List<dynamic> tokens,
    List<int> shape,
  ) async {
    final session = _textSession;
    if (session == null) {
      throw StateError(
        'OnnxModelService has not been initialized or session failed to load.',
      );
    }

    final runOptions = OrtRunOptions();
    final inputOrt = OrtValueTensor.createTensorWithDataList(tokens, shape);
    final inputs = {'input': inputOrt};
    final outputs = await session.runAsync(runOptions, inputs);
    inputOrt.release();
    runOptions.release();

    if (outputs == null || outputs.isEmpty || outputs.first == null) {
      throw StateError('ONNX model returned empty output.');
    }

    final outputTensor = outputs.first!.value as List<dynamic>;
    final result = <double>[];
    for (final val in outputTensor) {
      if (val is List) {
        for (final item in val) {
          result.add((item as num).toDouble());
        }
      } else {
        result.add((val as num).toDouble());
      }
    }

    for (final out in outputs) {
      out?.release();
    }

    return result;
  }

  /// Disposes active sessions.
  void dispose() {
    _textSession?.release();
    _textSession = null;
    _initialized = false;
  }
}
