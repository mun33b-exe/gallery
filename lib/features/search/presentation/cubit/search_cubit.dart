import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/ai_photo_search_repository.dart';
import 'search_state.dart';

/// Cubit managing AI natural-language photo search queries, suggestions,
/// and recent query history.
class SearchCubit extends Cubit<SearchState> {
  final AiPhotoSearchRepository searchRepository;

  SearchCubit({required this.searchRepository}) : super(const SearchInitial());

  /// Loads suggested prompt suggestions and recent search history.
  Future<void> loadInitial() async {
    try {
      final prompts = await searchRepository.getSuggestedPrompts();
      final recents = await searchRepository.getRecentSearches();
      emit(SearchInitial(suggestedPrompts: prompts, recentSearches: recents));
    } catch (_) {
      emit(const SearchInitial());
    }
  }

  /// Submits a query to the search repository.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await loadInitial();
      return;
    }

    emit(SearchLoading(query: trimmed));

    try {
      await searchRepository.saveRecentSearch(trimmed);
      final prompts = await searchRepository.getSuggestedPrompts();
      final results = await searchRepository.searchPhotos(query: trimmed);

      if (results.isEmpty) {
        emit(SearchEmpty(query: trimmed, suggestedPrompts: prompts));
      } else {
        emit(
          SearchSuccess(
            query: trimmed,
            results: results,
            suggestedPrompts: prompts,
          ),
        );
      }
    } catch (e) {
      emit(
        SearchError(
          query: trimmed,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears active search results and returns to initial prompt suggestions.
  Future<void> clearSearch() async {
    await loadInitial();
  }

  /// Clears recent searches list.
  Future<void> clearRecentSearches() async {
    await searchRepository.clearRecentSearches();
    try {
      final prompts = await searchRepository.getSuggestedPrompts();
      emit(SearchInitial(suggestedPrompts: prompts, recentSearches: const []));
    } catch (_) {
      emit(const SearchInitial());
    }
  }
}
