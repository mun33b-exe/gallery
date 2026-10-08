import 'package:equatable/equatable.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';

import '../../domain/search_message_model.dart';

/// Base state for AI Photo Search.
abstract class SearchState extends Equatable {
  final List<SearchMessage> messages;

  const SearchState({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

/// Initial state displaying suggested prompt chips and recent search history.
class SearchInitial extends SearchState {
  final List<String> suggestedPrompts;
  final List<String> recentSearches;

  const SearchInitial({
    super.messages,
    this.suggestedPrompts = const [],
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [messages, suggestedPrompts, recentSearches];
}

/// Executing a natural-language search query.
class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({super.messages, required this.query});

  @override
  List<Object?> get props => [messages, query];
}

/// Search completed with one or more matching photos or AI evidence.
class SearchSuccess extends SearchState {
  final String query;
  final List<PhotoModel> results;
  final List<String> suggestedPrompts;

  const SearchSuccess({
    super.messages,
    required this.query,
    required this.results,
    this.suggestedPrompts = const [],
  });

  @override
  List<Object?> get props => [messages, query, results, suggestedPrompts];
}

/// Search completed but zero photos or evidence matched the query.
class SearchEmpty extends SearchState {
  final String query;
  final List<String> suggestedPrompts;

  const SearchEmpty({
    super.messages,
    required this.query,
    this.suggestedPrompts = const [],
  });

  @override
  List<Object?> get props => [messages, query, suggestedPrompts];
}

/// An error occurred during search execution.
class SearchError extends SearchState {
  final String query;
  final String message;

  const SearchError({
    super.messages,
    required this.query,
    required this.message,
  });

  @override
  List<Object?> get props => [messages, query, message];
}
