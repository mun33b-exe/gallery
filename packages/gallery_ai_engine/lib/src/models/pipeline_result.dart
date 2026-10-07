/// High-level routing classification for an image.
enum ImageClassification {
  photo,
  document,
  uncertain;

  static ImageClassification fromIndex(int index) {
    switch (index) {
      case 0:
        return ImageClassification.photo;
      case 1:
        return ImageClassification.document;
      case 2:
      default:
        return ImageClassification.uncertain;
    }
  }

  String get labelString {
    switch (this) {
      case ImageClassification.photo:
        return 'Photo';
      case ImageClassification.document:
        return 'Document';
      case ImageClassification.uncertain:
        return 'Uncertain';
    }
  }
}

/// Output of the linear classifier head.
class ClassificationResult {
  final ImageClassification label;
  final List<double> logits;
  final List<double> probabilities;
  final double confidence;

  ClassificationResult({
    required this.label,
    required this.logits,
    required this.probabilities,
    required this.confidence,
  });

  bool get isPhoto => label == ImageClassification.photo;
  bool get isDocument => label == ImageClassification.document;
  bool get isUncertain => label == ImageClassification.uncertain;

  Map<String, dynamic> toJson() => {
        'label': label.labelString,
        'logits': logits,
        'probabilities': probabilities,
        'confidence': confidence,
      };
}

/// Category of document identified after OCR inspection.
enum DocumentType {
  /// Bills, invoices, receipts, fee challans, transaction screenshots.
  financial,

  /// CNIC/ID cards, degrees, bonafide certificates, notes, letters.
  informational,

  /// Non-document or unidentifiable.
  unknown;

  String get typeName {
    switch (this) {
      case DocumentType.financial:
        return 'Financial';
      case DocumentType.informational:
        return 'Informational';
      case DocumentType.unknown:
        return 'Unknown';
    }
  }
}

/// Outcome of the offline regex and math validation gate.
enum GateStatus {
  /// Math verified offline: abs((subtotal + tax) - total) <= 0.05. Zero cloud cost.
  passedOffline,

  /// Informational document (ID card, certificate). Saved to SQLite FTS5 index.
  informationalOffline,

  /// Financial document, but (subtotal + tax) does not equal total.
  failedMath,

  /// Financial document, but total or subtotal/tax amounts could not be detected.
  missingFields;

  bool get needsCloudEscalation =>
      this == GateStatus.failedMath || this == GateStatus.missingFields;
}

/// Structured fields extracted from a financial document.
class FinancialFields {
  final String? vendor;
  final String? date;
  final String currency;
  final double? subtotal;
  final double? tax;
  final double? total;
  final double? mathDifference;
  final bool isMathBalanced;
  final Map<String, dynamic> rawFields;

  FinancialFields({
    this.vendor,
    this.date,
    this.currency = 'USD',
    this.subtotal,
    this.tax,
    this.total,
    this.mathDifference,
    this.isMathBalanced = false,
    Map<String, dynamic>? rawFields,
  }) : rawFields = rawFields ?? {};

  Map<String, dynamic> toJson() => {
        'vendor': vendor,
        'date': date,
        'currency': currency,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'mathDifference': mathDifference,
        'isMathBalanced': isMathBalanced,
        'rawFields': rawFields,
      };

  factory FinancialFields.fromJson(Map<String, dynamic> json) {
    return FinancialFields(
      vendor: json['vendor'] as String?,
      date: json['date'] as String?,
      currency: (json['currency'] as String?) ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      mathDifference: (json['mathDifference'] as num?)?.toDouble(),
      isMathBalanced: (json['isMathBalanced'] as bool?) ?? false,
      rawFields: (json['rawFields'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Result of evaluating the document through the sanity gate.
class SanityGateResult {
  final DocumentType docType;
  final GateStatus status;
  final bool isFinancial;
  final FinancialFields? fields;
  final String reason;

  SanityGateResult({
    required this.docType,
    required this.status,
    required this.isFinancial,
    this.fields,
    required this.reason,
  });

  bool get needsCloudEscalation => status.needsCloudEscalation;

  Map<String, dynamic> toJson() => {
        'docType': docType.typeName,
        'status': status.name,
        'isFinancial': isFinancial,
        'fields': fields?.toJson(),
        'reason': reason,
        'needsCloudEscalation': needsCloudEscalation,
      };
}

/// Metadata extracted from EXIF and MediaStore.
class PhotoMetadata {
  final String mediaId;
  final String filePath;
  final DateTime? captureDate;
  final double? latitude;
  final double? longitude;
  final String? city;

  PhotoMetadata({
    required this.mediaId,
    required this.filePath,
    this.captureDate,
    this.latitude,
    this.longitude,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'mediaId': mediaId,
        'filePath': filePath,
        'captureDate': captureDate?.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
      };
}

/// Comprehensive record representing an indexed photo/document.
class IndexedRecord {
  final PhotoMetadata metadata;
  final List<double> embedding;
  final ClassificationResult classification;
  final String? ocrText;
  final SanityGateResult? gateResult;
  final String processingStatus;

  IndexedRecord({
    required this.metadata,
    required this.embedding,
    required this.classification,
    this.ocrText,
    this.gateResult,
    required this.processingStatus,
  });

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'classification': classification.toJson(),
        'hasOcrText': ocrText != null && ocrText!.isNotEmpty,
        'gateResult': gateResult?.toJson(),
        'processingStatus': processingStatus,
      };
}

/// Search result returned by the semantic or hybrid search engine.
class SearchResult {
  final String mediaId;
  final String filePath;
  final double similarityScore;
  final DateTime? captureDate;
  final String? city;
  final String? matchedSnippet;
  final FinancialFields? financialData;

  SearchResult({
    required this.mediaId,
    required this.filePath,
    required this.similarityScore,
    this.captureDate,
    this.city,
    this.matchedSnippet,
    this.financialData,
  });

  Map<String, dynamic> toJson() => {
        'mediaId': mediaId,
        'filePath': filePath,
        'similarityScore': similarityScore,
        'captureDate': captureDate?.toIso8601String(),
        'city': city,
        'matchedSnippet': matchedSnippet,
        'financialData': financialData?.toJson(),
      };
}
