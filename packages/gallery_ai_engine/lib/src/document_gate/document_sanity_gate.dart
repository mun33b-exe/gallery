import '../models/pipeline_result.dart';

/// Offline Document Categorizer and Mathematical Sanity Gate.
///
/// Evaluates raw OCR text lines, separates Informational vs Financial documents,
/// attempts Regex heuristic field extraction, and enforces the mathematical invariant:
///
///   abs((Subtotal + Tax) - Total) <= 0.05
///
/// Documents that pass the math gate stay 100% offline.
/// Informational documents stay 100% offline (indexed into SQLite FTS5).
/// Only failed/complex financial documents are routed to Cloud Escalation.
class DocumentSanityGate {
  static const double mathTolerance = 0.05;

  static const List<String> financialKeywords = [
    'total',
    'amount',
    'tax',
    'subtotal',
    'invoice',
    'receipt',
    'fee',
    'payment',
    'balance',
    'due',
    'challan',
    'bill',
    'paid',
    'price',
    'gst',
    'vat',
  ];

  static const List<String> informationalKeywords = [
    'republic',
    'government',
    'identity',
    'cnic',
    'certificate',
    'bonafide',
    'degree',
    'diploma',
    'license',
    'passport',
    'card',
    'university',
    'school',
    'letter',
  ];

  /// Evaluates OCR text lines and determines document routing & extraction status.
  SanityGateResult evaluate(List<String> textLines) {
    if (textLines.isEmpty) {
      return SanityGateResult(
        docType: DocumentType.unknown,
        status: GateStatus.missingFields,
        isFinancial: false,
        reason: 'No text lines detected in document.',
      );
    }

    final String fullTextLower = textLines.join(' ').toLowerCase();

    // 1. Detect if it contains financial keywords
    final bool hasFinancialSignal =
        financialKeywords.any((kw) => fullTextLower.contains(kw));
    final bool hasInformationalSignal =
        informationalKeywords.any((kw) => fullTextLower.contains(kw));

    if (!hasFinancialSignal && hasInformationalSignal) {
      return SanityGateResult(
        docType: DocumentType.informational,
        status: GateStatus.informationalOffline,
        isFinancial: false,
        reason:
            'Informational document (ID card, certificate, letter). Indexed offline to FTS5.',
      );
    }

    if (!hasFinancialSignal) {
      return SanityGateResult(
        docType: DocumentType.informational,
        status: GateStatus.informationalOffline,
        isFinancial: false,
        reason:
            'No financial indicators found. Preserved as offline informational document.',
      );
    }

    // 2. Financial document detected -> Parse fields via Regex
    final financialFields = _parseFinancialRegex(textLines);

    // 3. Mathematical Sanity Check
    final total = financialFields.total;
    final subtotal = financialFields.subtotal;
    final tax =
        financialFields.tax ?? 0.0; // If tax is not listed, tax can be 0.0

    if (total == null) {
      return SanityGateResult(
        docType: DocumentType.financial,
        status: GateStatus.missingFields,
        isFinancial: true,
        fields: financialFields,
        reason:
            'Financial document detected, but total amount could not be parsed.',
      );
    }

    if (subtotal == null) {
      // If we have total, but no subtotal breakdown, verify if tax was 0 or single line
      return SanityGateResult(
        docType: DocumentType.financial,
        status: GateStatus.missingFields,
        isFinancial: true,
        fields: financialFields,
        reason: 'Missing subtotal breakdown. Queuing for cloud VLM extraction.',
      );
    }

    final double expectedTotal = subtotal + tax;
    final double diff = (expectedTotal - total).abs();

    if (diff <= mathTolerance) {
      final verifiedFields = FinancialFields(
        vendor: financialFields.vendor,
        date: financialFields.date,
        currency: financialFields.currency,
        subtotal: subtotal,
        tax: tax,
        total: total,
        mathDifference: diff,
        isMathBalanced: true,
        rawFields: financialFields.rawFields,
      );

      return SanityGateResult(
        docType: DocumentType.financial,
        status: GateStatus.passedOffline,
        isFinancial: true,
        fields: verifiedFields,
        reason:
            'Math verified: Subtotal ($subtotal) + Tax ($tax) == Total ($total) [diff: ${diff.toStringAsFixed(3)}].',
      );
    } else {
      final unverifiedFields = FinancialFields(
        vendor: financialFields.vendor,
        date: financialFields.date,
        currency: financialFields.currency,
        subtotal: subtotal,
        tax: tax,
        total: total,
        mathDifference: diff,
        isMathBalanced: false,
        rawFields: financialFields.rawFields,
      );

      return SanityGateResult(
        docType: DocumentType.financial,
        status: GateStatus.failedMath,
        isFinancial: true,
        fields: unverifiedFields,
        reason:
            'Math mismatch: Subtotal ($subtotal) + Tax ($tax) != Total ($total) [diff: ${diff.toStringAsFixed(2)}]. Escalating to Gemini.',
      );
    }
  }

  /// Internal Regex heuristics to extract vendor, date, currency, and monetary figures.
  FinancialFields _parseFinancialRegex(List<String> lines) {
    String? vendor;
    String? date;
    String currency = 'USD';
    double? total;
    double? subtotal;
    double? tax;

    // Detect currency
    final fullText = lines.join(' ');
    if (fullText.contains(RegExp(r'PKR|Rs\.?|Rupees', caseSensitive: false))) {
      currency = 'PKR';
    } else if (fullText.contains(RegExp(r'€|EUR|Euro', caseSensitive: false))) {
      currency = 'EUR';
    } else if (fullText
        .contains(RegExp(r'£|GBP|Pound', caseSensitive: false))) {
      currency = 'GBP';
    } else if (fullText.contains(RegExp(r'\$|USD', caseSensitive: false))) {
      currency = 'USD';
    }

    // Heuristic Vendor: First non-empty line that doesn't look like pure numbers
    for (final line in lines.take(4)) {
      final trimmed = line.trim();
      if (trimmed.length > 2 && !RegExp(r'^\d+$').hasMatch(trimmed)) {
        vendor = trimmed;
        break;
      }
    }

    // Date Pattern: YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY
    final dateRegex = RegExp(r'\b(\d{1,4}[-/]\d{1,2}[-/]\d{1,4})\b');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        date = match.group(1);
        break;
      }
    }

    // Extract Amounts
    for (final line in lines) {
      final lower = line.toLowerCase();

      if (lower.contains('subtotal') ||
          lower.contains('sub-total') ||
          lower.contains('sub total')) {
        subtotal ??= _extractDecimalFromLine(line);
      } else if (lower.contains('tax') ||
          lower.contains('vat') ||
          lower.contains('gst')) {
        tax ??= _extractDecimalFromLine(line);
      } else if (lower.contains('total') ||
          lower.contains('amount due') ||
          lower.contains('net amount')) {
        total ??= _extractDecimalFromLine(line);
      }
    }

    return FinancialFields(
      vendor: vendor,
      date: date,
      currency: currency,
      subtotal: subtotal,
      tax: tax,
      total: total,
      rawFields: {'extractedLinesCount': lines.length},
    );
  }

  /// Extracts the largest decimal number from a string line.
  double? _extractDecimalFromLine(String line) {
    final regex = RegExp(r'(\d+[\.,]\d{2})');
    final matches = regex.allMatches(line);
    if (matches.isEmpty) return null;

    // Convert comma decimal to dot decimal and parse
    for (final match in matches) {
      final raw = match.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(raw);
      if (val != null) return val;
    }
    return null;
  }
}
