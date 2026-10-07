import 'dart:convert';
import '../models/pipeline_result.dart';

/// Client interface for Cloud Escalation when on-device Regex math fails.
/// Calls the FastAPI `/extract` endpoint or direct Gemini 3.1 Flash-Lite API.
class GeminiFallbackClient {
  final String backendUrl;
  final String? apiKey;

  GeminiFallbackClient({
    this.backendUrl = 'https://api.yourdomain.com/extract',
    this.apiKey,
  });

  /// Strict Gemini JSON Schema prompt template
  static const String extractionSystemPrompt = '''
You are an expert document and receipt financial data extractor.
Extract the structured data in valid JSON matching this schema:
{
  "vendor": "string (business or authority name)",
  "date": "string (YYYY-MM-DD format if known)",
  "currency": "string (ISO 3-letter code, e.g. USD, PKR, EUR)",
  "subtotal": "number (float) or null",
  "tax": "number (float) or null",
  "total": "number (float)",
  "items": [
    {"description": "string", "amount": "number"}
  ]
}
Do not include markdown fences or extraneous text. Return ONLY the raw JSON object.
''';

  /// Prepares the payload for escalation
  Map<String, dynamic> buildPayload({
    required String mediaId,
    required String base64Image,
    required String mimeType,
    List<String>? priorOcrLines,
  }) {
    return {
      'media_id': mediaId,
      'image_base64': base64Image,
      'mime_type': mimeType,
      'prior_ocr_hint': priorOcrLines?.join('\n'),
      'prompt': extractionSystemPrompt,
    };
  }

  /// Parses the returned Gemini JSON into verified FinancialFields
  FinancialFields parseGeminiResponse(String responseJsonString) {
    try {
      // Remove any unintentional backticks
      var cleaned = responseJsonString.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      final Map<String, dynamic> map = jsonDecode(cleaned);

      final total = (map['total'] as num?)?.toDouble();
      final subtotal = (map['subtotal'] as num?)?.toDouble();
      final tax = (map['tax'] as num?)?.toDouble() ?? 0.0;
      final currency = (map['currency'] as String?) ?? 'USD';

      bool balanced = false;
      double? diff;
      if (total != null && subtotal != null) {
        diff = ((subtotal + tax) - total).abs();
        balanced = diff <= 0.05;
      }

      return FinancialFields(
        vendor: map['vendor'] as String?,
        date: map['date'] as String?,
        currency: currency,
        subtotal: subtotal,
        tax: tax,
        total: total,
        mathDifference: diff,
        isMathBalanced: balanced,
        rawFields: map,
      );
    } catch (e) {
      throw FormatException('Failed to parse Gemini extraction JSON: $e');
    }
  }
}
