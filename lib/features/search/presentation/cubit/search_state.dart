import 'package:equatable/equatable.dart';

import 'package:gallery/features/gallery/domain/photo_model.dart';

/// Base state for AI Photo Search.
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state displaying suggested prompt chips and recent search history.
class SearchInitial extends SearchState {
  final List<String> suggestedPrompts;
  final List<String> recentSearches;

  const SearchInitial({
    this.suggestedPrompts = const [],
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [suggestedPrompts, recentSearches];
}

/// Executing a natural-language search query.
class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Search completed with one or more matching photos.
class SearchSuccess extends SearchState {
  final String query;
  final List<PhotoModel> results;
  final List<String> suggestedPrompts;

  const SearchSuccess({
    required this.query,
    required this.results,
    this.suggestedPrompts = const [],
  });

  @override
  List<Object?> get props => [query, results, suggestedPrompts];
}

/// Search completed but zero photos matched the query.
class SearchEmpty extends SearchState {
  final String query;
  final List<String> suggestedPrompts;

  const SearchEmpty({required this.query, this.suggestedPrompts = const []});

  @override
  List<Object?> get props => [query, suggestedPrompts];
}

/// An error occurred during search execution.
class SearchError extends SearchState {
  final String query;
  final String message;

  const SearchError({required this.query, required this.message});

  @override
  List<Object?> get props => [query, message];
}
