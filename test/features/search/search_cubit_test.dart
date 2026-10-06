import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/search/data/mock_ai_photo_search_repository.dart';
import 'package:gallery/features/search/presentation/cubit/search_cubit.dart';
import 'package:gallery/features/search/presentation/cubit/search_state.dart';

void main() {
  group('SearchCubit State Transitions', () {
    late MockAiPhotoSearchRepository repository;
    late SearchCubit cubit;

    setUp(() {
      repository = MockAiPhotoSearchRepository(
        simulatedDelay: Duration.zero,
        initialRecentSearches: ['dogs', 'sunset'],
      );
      cubit = SearchCubit(searchRepository: repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is SearchInitial with empty prompts and recents', () {
      expect(cubit.state, isA<SearchInitial>());
      final state = cubit.state as SearchInitial;
      expect(state.suggestedPrompts, isEmpty);
      expect(state.recentSearches, isEmpty);
    });

    test(
      'loadInitial populates suggested prompts and recent searches',
      () async {
        await cubit.loadInitial();

        expect(cubit.state, isA<SearchInitial>());
        final state = cubit.state as SearchInitial;
        expect(state.suggestedPrompts, isNotEmpty);
        expect(state.suggestedPrompts, contains('Show photos of dogs'));
        expect(state.recentSearches, equals(['dogs', 'sunset']));
      },
    );

    test(
      'search with valid query emits SearchLoading and then SearchSuccess',
      () async {
        final states = <SearchState>[];
        cubit.stream.listen(states.add);

        await cubit.search('dogs');
        await pumpEventQueue();

        expect(states.length, 2);
        expect(states[0], isA<SearchLoading>());
        expect((states[0] as SearchLoading).query, equals('dogs'));

        expect(states[1], isA<SearchSuccess>());
        final success = states[1] as SearchSuccess;
        expect(success.query, equals('dogs'));
        expect(success.results, isNotEmpty);
        expect(
          success.results.every(
            (p) =>
                (p.title ?? '').toLowerCase().contains('dog') ||
                (p.title ?? '').toLowerCase().contains('puppy') ||
                (p.title ?? '').toLowerCase().contains('retriever'),
          ),
          isTrue,
        );
        expect(success.suggestedPrompts, isNotEmpty);
      },
    );

    test(
      'search with whitespace or empty query resets to SearchInitial',
      () async {
        await cubit.search('dogs');
        expect(cubit.state, isA<SearchSuccess>());

        await cubit.search('   ');
        expect(cubit.state, isA<SearchInitial>());
      },
    );

    test('search yielding no matches emits SearchEmpty', () async {
      final states = <SearchState>[];
      cubit.stream.listen(states.add);

      await cubit.search('empty');
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<SearchLoading>());
      expect(states[1], isA<SearchEmpty>());
      final emptyState = states[1] as SearchEmpty;
      expect(emptyState.query, equals('empty'));
      expect(emptyState.suggestedPrompts, isNotEmpty);
    });

    test(
      'search failure emits SearchError with message and allows retry',
      () async {
        final states = <SearchState>[];
        cubit.stream.listen(states.add);

        await cubit.search('error_simulate');
        await pumpEventQueue();

        expect(states.length, 2);
        expect(states[0], isA<SearchLoading>());
        expect(states[1], isA<SearchError>());
        final errorState = states[1] as SearchError;
        expect(errorState.query, equals('error_simulate'));
        expect(
          errorState.message,
          contains('Simulated AI search engine failure'),
        );

        // Retry with successful query
        await cubit.search('beach');
        expect(cubit.state, isA<SearchSuccess>());
        expect((cubit.state as SearchSuccess).query, equals('beach'));
      },
    );

    test('clearSearch returns to SearchInitial with latest history', () async {
      await cubit.search('beach');
      expect(cubit.state, isA<SearchSuccess>());

      await cubit.clearSearch();
      expect(cubit.state, isA<SearchInitial>());
      final state = cubit.state as SearchInitial;
      expect(state.recentSearches.first, equals('beach'));
    });

    test('clearRecentSearches clears stored search history', () async {
      await cubit.loadInitial();
      expect((cubit.state as SearchInitial).recentSearches, isNotEmpty);

      await cubit.clearRecentSearches();

      expect(cubit.state, isA<SearchInitial>());
      final state = cubit.state as SearchInitial;
      expect(state.recentSearches, isEmpty);
      expect(state.suggestedPrompts, isNotEmpty);
    });
  });
}
