import 'dart:typed_data';

import 'document_gate/document_sanity_gate.dart';
import 'inference/classifier_head.dart';
import 'inference/ocr_engine.dart';
import 'inference/text_engine.dart';
import 'inference/vision_engine.dart';
import 'models/pipeline_result.dart';
import 'preprocessing/image_preprocessor.dart';
import 'vector_search/vector_math.dart';

/// The Master Orchestrator for Edge-First AI Gallery & Document Search.
///
/// Encapsulates the entire 7-step pipeline:
///  EXIF -> MobileCLIP Vision -> Linear Head Routing -> Local PP-OCRv4 -> Regex Math Gate -> Cloud Queue
class GalleryAIEngine {
  final VisionEngine visionEngine;
  final TextEngine textEngine;
  final ClassifierHead classifierHead;
  final BaseOcrEngine ocrEngine;
  final DocumentSanityGate sanityGate;

  GalleryAIEngine({
    required this.visionEngine,
    required this.textEngine,
    required this.classifierHead,
    required this.ocrEngine,
    DocumentSanityGate? sanityGate,
  }) : sanityGate = sanityGate ?? DocumentSanityGate();

  /// Factory constructor to quickly build the engine from an ONNX runner and OCR runner.
  factory GalleryAIEngine.create({
    required OnnxTensorRunner onnxRunner,
    required Future<List<String>> Function(String path) ocrRunner,
    required String classifierWeightsJson,
  }) {
    final head = ClassifierHead();
    head.loadWeightsFromJson(classifierWeightsJson);

    return GalleryAIEngine(
      visionEngine: VisionEngine(runner: onnxRunner),
      textEngine: TextEngine(runner: onnxRunner),
      classifierHead: head,
      ocrEngine: LocalDocumentOcrEngine(ocrRunner: ocrRunner),
    );
  }

  /// Processes an image from the device gallery through the background indexing gauntlet.
  ///
  /// [metadata]: EXIF and MediaStore info (capture date, GPS, path).
  /// [pixelBytes]: Raw decoded pixel bytes (RGBA or RGB) of the image.
  /// [imageWidth]: Original image width.
  /// [imageHeight]: Original image height.
  /// [hasAlpha]: True if RGBA, false if RGB.
  Future<IndexedRecord> indexImage({
    required PhotoMetadata metadata,
    required Uint8List pixelBytes,
    required int imageWidth,
    required int imageHeight,
    bool hasAlpha = true,
  }) async {
    // 1. Preprocess Image to [1, 3, 256, 256] Float32 tensor
    final preprocessedTensor = ImagePreprocessor.preprocessPixelBuffer(
      bytes: pixelBytes,
      width: imageWidth,
      height: imageHeight,
      hasAlpha: hasAlpha,
    );

    // 2. MobileCLIP Vision Embedding (512-D normalized vector)
    final embedding = await visionEngine.embedImage(preprocessedTensor);

    // 3. Routing Classifier (Linear Head, < 0.1ms)
    final classification = classifierHead.classify(embedding);

    // Branch A: Standard Photo
    if (classification.isPhoto) {
      return IndexedRecord(
        metadata: metadata,
        embedding: embedding,
        classification: classification,
        ocrText: null,
        gateResult: null,
        processingStatus: 'INDEXED_PHOTO_OFFLINE',
      );
    }

    // Branch B: Document (Receipts, bills, certificates, CNIC)
    if (classification.isDocument) {
      // Run Local OCR
      final ocrLines = await ocrEngine.extractLines(metadata.filePath);
      final rawOcrText = ocrLines.join('\n');

      // Run Document Sanity Gate
      final gateResult = sanityGate.evaluate(ocrLines);

      String processingStatus;
      switch (gateResult.status) {
        case GateStatus.passedOffline:
          processingStatus = 'INDEXED_FINANCIAL_OFFLINE';
          break;
        case GateStatus.informationalOffline:
          processingStatus = 'INDEXED_INFORMATIONAL_OFFLINE';
          break;
        case GateStatus.failedMath:
        case GateStatus.missingFields:
          processingStatus = 'QUEUED_CLOUD_ESCALATION';
          break;
      }

      return IndexedRecord(
        metadata: metadata,
        embedding: embedding,
        classification: classification,
        ocrText: rawOcrText,
        gateResult: gateResult,
        processingStatus: processingStatus,
      );
    }

    // Branch C: Uncertain (Screenshots, posters, menus)
    // Run lightweight OCR check to see if text is present
    final ocrLines = await ocrEngine.extractLines(metadata.filePath);
    final rawOcrText = ocrLines.join('\n');

    SanityGateResult? gateResult;
    String status = 'INDEXED_UNCERTAIN_OFFLINE';

    if (ocrLines.length > 5) {
      // Substantial text found: treat as document
      gateResult = sanityGate.evaluate(ocrLines);
      if (gateResult.needsCloudEscalation) {
        status = 'QUEUED_CLOUD_ESCALATION';
      } else {
        status = gateResult.isFinancial
            ? 'INDEXED_FINANCIAL_OFFLINE'
            : 'INDEXED_INFORMATIONAL_OFFLINE';
      }
    }

    return IndexedRecord(
      metadata: metadata,
      embedding: embedding,
      classification: classification,
      ocrText: rawOcrText.isNotEmpty ? rawOcrText : null,
      gateResult: gateResult,
      processingStatus: status,
    );
  }

  /// Executes natural language semantic search across indexed image records.
  ///
  /// [query]: Text typed into the search bar (e.g. "my dog in the park").
  /// [storedRecords]: The list of existing records with embeddings.
  /// [topK]: Maximum number of results to return.
  Future<List<SearchResult>> semanticSearch({
    required String query,
    required List<IndexedRecord> storedRecords,
    int topK = 20,
    double minThreshold = 0.15,
  }) async {
    // 1. Embed query text into 512-D vector
    final queryVector = await textEngine.embedQuery(query);

    // 2. Rank using Cosine Similarity
    final ranked = VectorMath.topK<IndexedRecord>(
      queryVector: queryVector,
      items: storedRecords,
      vectorExtractor: (rec) => rec.embedding,
      k: topK,
      minThreshold: minThreshold,
    );

    // 3. Transform to SearchResult objects
    return ranked.map((r) {
      final rec = r.item;
      return SearchResult(
        mediaId: rec.metadata.mediaId,
        filePath: rec.metadata.filePath,
        similarityScore: r.score,
        captureDate: rec.metadata.captureDate,
        city: rec.metadata.city,
        matchedSnippet: rec.ocrText != null
            ? (rec.ocrText!.length > 100
                ? '${rec.ocrText!.substring(0, 100)}...'
                : rec.ocrText)
            : null,
        financialData: rec.gateResult?.fields,
      );
    }).toList();
  }
}
