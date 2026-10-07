/// A recognized text block from local OCR.
class OcrTextBlock {
  final String text;
  final double confidence;
  final List<int>? boundingBox; // [x1, y1, x2, y2]

  OcrTextBlock({
    required this.text,
    this.confidence = 1.0,
    this.boundingBox,
  });
}

/// Abstract contract for offline OCR engines (PP-OCRv4 or Google ML Kit).
abstract class BaseOcrEngine {
  /// Extracts all text lines from an image.
  Future<List<String>> extractLines(String imagePath);

  /// Extracts structured text blocks with confidence and coordinates.
  Future<List<OcrTextBlock>> extractBlocks(String imagePath);
}

/// Generic implementation bridging PP-OCRv4 ONNX models or native mobile OCR.
class LocalDocumentOcrEngine implements BaseOcrEngine {
  final Future<List<String>> Function(String imagePath) ocrRunner;

  LocalDocumentOcrEngine({required this.ocrRunner});

  @override
  Future<List<String>> extractLines(String imagePath) async {
    return await ocrRunner(imagePath);
  }

  @override
  Future<List<OcrTextBlock>> extractBlocks(String imagePath) async {
    final lines = await extractLines(imagePath);
    return lines.map((line) => OcrTextBlock(text: line)).toList();
  }
}
