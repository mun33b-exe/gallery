import 'package:equatable/equatable.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';

/// Document or receipt evidence extracted by the AI gallery assistant.
class DocumentEvidenceModel extends Equatable {
  final String serviceName;
  final String dueDate;
  final String? amount;
  final PhotoModel? receiptPhoto;

  const DocumentEvidenceModel({
    required this.serviceName,
    required this.dueDate,
    this.amount,
    this.receiptPhoto,
  });

  @override
  List<Object?> get props => [serviceName, dueDate, amount, receiptPhoto];
}

/// Itemized financial entry for financial reasoning responses.
class FinancialItemModel extends Equatable {
  final String title;
  final String amount;

  const FinancialItemModel({required this.title, required this.amount});

  @override
  List<Object?> get props => [title, amount];
}

/// Structured financial analysis summary.
class FinancialBreakdownModel extends Equatable {
  final String category;
  final String totalAmount;
  final List<FinancialItemModel> items;

  const FinancialBreakdownModel({
    required this.category,
    required this.totalAmount,
    this.items = const [],
  });

  @override
  List<Object?> get props => [category, totalAmount, items];
}

/// A conversational message in the AI Gallery Search session.
class SearchMessage extends Equatable {
  final String id;
  final bool isUser;
  final String text;
  final List<PhotoModel> photos;
  final DocumentEvidenceModel? documentEvidence;
  final FinancialBreakdownModel? financialBreakdown;
  final String? sourceContext;
  final int? totalCount;
  final DateTime timestamp;

  const SearchMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.photos = const [],
    this.documentEvidence,
    this.financialBreakdown,
    this.sourceContext,
    this.totalCount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    isUser,
    text,
    photos,
    documentEvidence,
    financialBreakdown,
    sourceContext,
    totalCount,
    timestamp,
  ];
}
