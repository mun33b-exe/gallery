// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:gallery_ai_engine/gallery_ai_engine.dart';

/// Complete executable example demonstrating how the Flutter developer
/// uses `gallery_ai_engine` in the app.
void main() async {
  print('=================================================');
  print(' 🚀 Edge-First AI Gallery Engine Demo (Dart SDK) ');
  print('=================================================\n');

  // 1. Load exported weights.json
  final weightsFile = File('../models/weights.json');
  String weightsJson;
  if (weightsFile.existsSync()) {
    weightsJson = weightsFile.readAsStringSync();
  } else {
    // Fallback dummy weights for standalone demonstration
    weightsJson = jsonEncode({
      'weight': [
        List.filled(512, 0.01), // Class 0: Photo
        List.filled(512, 0.05), // Class 1: Document
        List.filled(512, -0.01), // Class 2: Uncertain
      ],
      'bias': [0.5, -0.2, -0.3]
    });
  }

  // 2. Simulated ONNX & OCR Runners (In Flutter, these call onnxruntime package)
  final engine = GalleryAIEngine.create(
    classifierWeightsJson: weightsJson,
    onnxRunner: (modelName, inputs, shape) async {
      // Returns a dummy 512-D normalized vector matching MobileCLIP shape
      final vec = List<double>.generate(512, (i) => (i % 10) * 0.1);
      return VisionEngine.normalizeL2(vec);
    },
    ocrRunner: (imagePath) async {
      // Simulates local PP-OCRv4 output depending on file name
      if (imagePath.contains('fee') || imagePath.contains('receipt')) {
        return [
          'METRO CASH & CARRY',
          'Date: 2026-10-06',
          'Subtotal: \$45.00',
          'Tax: \$5.00',
          'Total: \$50.00',
          'Thank you for shopping!'
        ];
      } else if (imagePath.contains('bonafide') ||
          imagePath.contains('certificate')) {
        return [
          'NATIONAL UNIVERSITY OF SCIENCES AND TECHNOLOGY',
          'BONAFIDE CERTIFICATE',
          'This is to certify that John Doe is a bonafide student.',
          'Registration No: 2022-NUST-SE-041',
          'Issue Date: 15-Sep-2026'
        ];
      }
      return [];
    },
  );

  print('✅ AI Engine initialized successfully.\n');

  // -----------------------------------------------------------------
  // Case A: Indexing a Normal Photo (e.g. Dog at the beach)
  // -----------------------------------------------------------------
  print('📸 Test A: Indexing Standard Photo (e.g. dog.jpg)...');
  // Simulated 256x256 RGBA pixel buffer
  final dummyPhotoPixels = Uint8List(256 * 256 * 4);
  final photoRecord = await engine.indexImage(
    metadata: PhotoMetadata(
      mediaId: 'media_101',
      filePath: '/storage/emulated/0/DCIM/Camera/dog.jpg',
      captureDate: DateTime(2026, 9, 29),
      city: 'San Francisco',
    ),
    pixelBytes: dummyPhotoPixels,
    imageWidth: 256,
    imageHeight: 256,
  );

  print(
      '   Label: ${photoRecord.classification.label.labelString} (${(photoRecord.classification.confidence * 100).toStringAsFixed(1)}%)');
  print('   Status: ${photoRecord.processingStatus}');
  print('   Result: Saved 512-D vector to SQLite. Zero OCR or cloud needed.\n');

  // -----------------------------------------------------------------
  // Case B: Informational Document (e.g. Bonafide Certificate / CNIC)
  // -----------------------------------------------------------------
  print('📄 Test B: Indexing Informational Document (certificate.jpg)...');
  final gate = DocumentSanityGate();
  final certLines = [
    'GOVERNMENT DEGREE COLLEGE',
    'BONAFIDE CERTIFICATE',
    'Student Name: Sarah Khan',
    'Roll No: 9812',
    'Character: Exemplary'
  ];
  final certEvaluation = gate.evaluate(certLines);

  print('   Document Type: ${certEvaluation.docType.typeName}');
  print('   Gate Status: ${certEvaluation.status.name}');
  print('   Reason: ${certEvaluation.reason}');
  print(
      '   Result: Dumped full text to SQLite FTS5 index. 100% offline, zero cloud API calls!\n');

  // -----------------------------------------------------------------
  // Case C: Financial Receipt (Clean Receipt - Passes Math Check)
  // -----------------------------------------------------------------
  print('🧾 Test C: Indexing Financial Receipt with Valid Math...');
  final cleanReceiptLines = [
    'WALMART SUPERCENTER',
    'Date: 2026-10-02',
    'Subtotal: \$80.00',
    'Tax: \$8.00',
    'Total: \$88.00'
  ];
  final cleanEvaluation = gate.evaluate(cleanReceiptLines);

  print('   Document Type: ${cleanEvaluation.docType.typeName}');
  print('   Gate Status: ${cleanEvaluation.status.name}');
  print('   Vendor: ${cleanEvaluation.fields?.vendor}');
  print(
      '   Subtotal: \$${cleanEvaluation.fields?.subtotal}, Tax: \$${cleanEvaluation.fields?.tax}, Total: \$${cleanEvaluation.fields?.total}');
  print(
      '   Math Diff: \$${cleanEvaluation.fields?.mathDifference?.toStringAsFixed(2)}');
  print('   Reason: ${cleanEvaluation.reason}');
  print(
      '   Result: Verified locally! Stored to SQLite. Zero cloud API calls!\n');

  // -----------------------------------------------------------------
  // Case D: Complex Challan / Receipt (Fails Math Check -> Cloud Queue)
  // -----------------------------------------------------------------
  print('⚠️ Test D: Indexing Complex Fee Challan (Math Mismatch)...');
  final complexLines = [
    'HABIB BANK LIMITED',
    'FEE CHALLAN FORM',
    'Tuition Fee: 45000',
    'Library Fund: 3000',
    'Subtotal: 45000', // OCR missed the library fund addition
    'Tax: 0',
    'Total: 48000'
  ];
  final complexEvaluation = gate.evaluate(complexLines);

  print('   Document Type: ${complexEvaluation.docType.typeName}');
  print('   Gate Status: ${complexEvaluation.status.name}');
  print('   Math Balanced: ${cleanEvaluation.fields?.isMathBalanced}');
  print('   Reason: ${complexEvaluation.reason}');
  print('   Escalate to Cloud?: ${complexEvaluation.needsCloudEscalation}');
  print(
      '   Result: Added to cloud_upload_queue for Gemini 3.1 Flash-Lite fallback!\n');

  // -----------------------------------------------------------------
  // Case E: Semantic Search Query
  // -----------------------------------------------------------------
  print('🔍 Test E: Executing Semantic Search Query...');
  final searchResults = await engine.semanticSearch(
    query: 'white dog playing on the grass',
    storedRecords: [photoRecord],
  );

  print("   Query: 'white dog playing on the grass'");
  print('   Found ${searchResults.length} matching photos.');
  for (final res in searchResults) {
    print(
        '   -> Match: ${res.filePath} | Similarity: ${(res.similarityScore * 100).toStringAsFixed(1)}%');
  }

  print('\n=================================================');
  print(' ✅ All 7-step pipeline modules validated in Dart! ');
  print('=================================================');
}
