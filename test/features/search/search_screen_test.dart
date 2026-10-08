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

    testWidgets(
      'conversational visual query (hilly areas) renders AI explanation, photo row with overflow, and source context',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        await tester.enterText(
          inputField,
          'Show me all the pictures of hilly areas',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // User bubble
        expect(
          find.text('Show me all the pictures of hilly areas'),
          findsWidgets,
        );

        // AI message & source context
        expect(
          find.text('Here are 42 photos of hilly areas from your gallery.'),
          findsOneWidget,
        );
        expect(find.text('From your gallery'), findsOneWidget);

        // Photo row and overflow card (+39)
        expect(find.byType(PhotoThumbnailTile), findsWidgets);
        expect(find.text('+39'), findsOneWidget);
        expect(find.text('See all'), findsOneWidget);
      },
    );

    testWidgets(
      'conversational document query (internet bill) renders structured bill evidence card',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        await tester.enterText(
          inputField,
          'What is the last date to pay the internet bill?',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // AI text explanation
        expect(
          find.text(
            'Based on the payment receipt screenshots in your gallery, the last date to pay your internet bill is:',
          ),
          findsOneWidget,
        );

        // Structured evidence card
        expect(find.text('25 September 2025'), findsOneWidget);
        expect(find.text('PTCL Broadband'), findsOneWidget);
        expect(
          find.text('Based on 1 payment receipt in your gallery'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'conversational financial query (subscription) renders itemized financial breakdown',
      (tester) async {
        await tester.pumpWidget(createSearchScreenTestApp());
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        await tester.enterText(
          inputField,
          'How much did I spend on subscription last month?',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // AI summary
        expect(
          find.text('You spent Rs 8,450 on subscriptions last month.'),
          findsOneWidget,
        );

        // Financial card
        expect(find.text('Monthly Subscriptions'), findsOneWidget);
        expect(find.text('Rs 8,450'), findsWidgets);
        expect(find.text('Netflix 4K Premium'), findsOneWidget);
        expect(find.text('Spotify Family'), findsOneWidget);
        expect(find.text('AWS Cloud Server'), findsOneWidget);
      },
    );
  });
}
