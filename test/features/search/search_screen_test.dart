import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:gallery/features/search/data/mock_ai_photo_search_repository.dart';
import 'package:gallery/features/search/presentation/cubit/search_cubit.dart';
import 'package:gallery/features/search/presentation/screens/search_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SearchScreen Widget Tests', () {
    late MockAiPhotoSearchRepository searchRepo;
    late SearchCubit searchCubit;
    late MockPhotoRepository photoRepo;
    late GalleryCubit galleryCubit;

    setUp(() {
      searchRepo = MockAiPhotoSearchRepository(
        simulatedDelay: Duration.zero,
        initialRecentSearches: ['dogs', 'beach sunset'],
      );
      searchCubit = SearchCubit(searchRepository: searchRepo);
      photoRepo = MockPhotoRepository(simulatedDelay: Duration.zero);
      galleryCubit = GalleryCubit(photoRepository: photoRepo);
    });

    tearDown(() async {
      await searchCubit.close();
      await galleryCubit.close();
    });

    Widget createSearchScreenTestApp() {
      final testRouter = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/photo-viewer',
            builder: (context, state) {
              final args = state.extra as PhotoViewerArgs;
              return Scaffold(
                body: Text(
                  'PhotoViewer: index ${args.initialIndex}, count ${args.photos.length}',
                ),
              );
            },
          ),
        ],
      );

      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<GalleryCubit>.value(value: galleryCubit),
          BlocProvider<SearchCubit>.value(value: searchCubit),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      );
    }

    testWidgets(
      'renders initial view with suggested prompt chips and recent searches',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Suggested Searches'), findsOneWidget);
        expect(find.text('Show photos of dogs'), findsOneWidget);
        expect(find.text('Show beach photos'), findsOneWidget);

        expect(find.text('Recent Searches'), findsOneWidget);
        expect(find.text('dogs'), findsOneWidget);
        expect(find.text('beach sunset'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping suggested prompt chip auto-populates input and triggers query',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final dogChip = find.text('Show photos of dogs');
        expect(dogChip, findsOneWidget);

        await tester.tap(dogChip);
        await tester.pumpAndSettle();

        // Verifies search input populated
        expect(find.text('Show photos of dogs'), findsWidgets);

        // Verifies results rendered
        expect(
          find.text('Found 2 photos for "Show photos of dogs"'),
          findsOneWidget,
        );
        expect(find.byType(PhotoThumbnailTile), findsNWidgets(2));
      },
    );

    testWidgets(
      'submitting search input triggers query and displays matching photo tiles',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        expect(inputField, findsOneWidget);

        await tester.enterText(inputField, 'cars');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text('Found 1 photos for "cars"'), findsOneWidget);
        expect(find.byType(PhotoThumbnailTile), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a result thumbnail seamlessly opens PhotoViewerScreen with collection and index',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        // Search for dogs
        await tester.tap(find.text('Show photos of dogs'));
        await tester.pumpAndSettle();

        final firstTile = find.byType(PhotoThumbnailTile).first;
        await tester.tap(firstTile);
        // Wait past any potential double-tap window
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.text('PhotoViewer: index 0, count 2'), findsOneWidget);
      },
    );

    testWidgets('tapping Clear next to Recent Searches clears query history', (
      tester,
    ) async {
      await tester.pumpWidget(createSearchScreenTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('beach sunset'), findsOneWidget);

      final clearButton = find.text('Clear');
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsNothing);
      expect(find.text('beach sunset'), findsNothing);
    });

    testWidgets(
      'empty search results view renders No Photos Found and suggested prompt chips',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        await tester.enterText(inputField, 'nonexistent');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text('No Photos Found'), findsOneWidget);
        expect(
          find.text(
            'We couldn\'t find any photos matching "nonexistent". Try a different natural-language prompt.',
          ),
          findsOneWidget,
        );
        expect(find.text('Try One of These Suggestions'), findsOneWidget);
      },
    );

    testWidgets('search error view renders error message and allows retry', (
      tester,
    ) async {
      await tester.pumpWidget(createSearchScreenTestApp());
      await tester.pumpAndSettle();

      final inputField = find.byType(TextField);
      await tester.enterText(inputField, 'error_simulate');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Search Failed'), findsOneWidget);
      expect(
        find.text('Simulated AI search engine failure. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);

      // Tap Try Again
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Still fails because query is unchanged 'error_simulate'
      expect(find.text('Search Failed'), findsOneWidget);
    });
  });
}
