import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/ai_photo_search_repository.dart';
import '../../domain/search_message_model.dart';
import 'search_state.dart';

/// Cubit managing AI natural-language photo search queries, suggestions,
/// conversational reasoning messages, and recent query history.
class SearchCubit extends Cubit<SearchState> {
  final AiPhotoSearchRepository searchRepository;
  final List<SearchMessage> _messages = [];

  SearchCubit({required this.searchRepository}) : super(const SearchInitial());

  List<SearchMessage> get messages => List.unmodifiable(_messages);

  /// Loads suggested prompt suggestions and recent search history.
  Future<void> loadInitial() async {
    try {
      final prompts = await searchRepository.getSuggestedPrompts();
      final recents = await searchRepository.getRecentSearches();
      emit(
        SearchInitial(
          messages: List.unmodifiable(_messages),
          suggestedPrompts: prompts,
          recentSearches: recents,
        ),
      );
    } catch (_) {
      emit(SearchInitial(messages: List.unmodifiable(_messages)));
    }
  }

  /// Submits a natural-language query to the conversational AI search engine.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await loadInitial();
      return;
    }

    final userMessage = SearchMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      isUser: true,
      text: trimmed,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    emit(SearchLoading(query: trimmed, messages: List.unmodifiable(_messages)));

    try {
      await searchRepository.saveRecentSearch(trimmed);
      final prompts = await searchRepository.getSuggestedPrompts();

      // Retrieve full multi-modal conversational AI response
      final aiMessage = await searchRepository.processAiQuery(trimmed);
      _messages.add(aiMessage);

      final results = aiMessage.photos;

      if (results.isEmpty &&
          aiMessage.documentEvidence == null &&
          aiMessage.financialBreakdown == null) {
        emit(
          SearchEmpty(
            query: trimmed,
            messages: List.unmodifiable(_messages),
            suggestedPrompts: prompts,
          ),
        );
      } else {
        emit(
          SearchSuccess(
            query: trimmed,
            results: results,
            messages: List.unmodifiable(_messages),
            suggestedPrompts: prompts,
          ),
        );
      }
    } catch (e) {
      emit(
        SearchError(
          query: trimmed,
          messages: List.unmodifiable(_messages),
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears active search conversation and returns to initial suggestions.
  Future<void> clearSearch() async {
    _messages.clear();
    await loadInitial();
  }

  /// Clears recent searches list.
  Future<void> clearRecentSearches() async {
    await searchRepository.clearRecentSearches();
    try {
      final prompts = await searchRepository.getSuggestedPrompts();
      emit(
        SearchInitial(
          messages: List.unmodifiable(_messages),
          suggestedPrompts: prompts,
          recentSearches: const [],
        ),
      );
    } catch (_) {
      emit(SearchInitial(messages: List.unmodifiable(_messages)));
    }
  }
}
