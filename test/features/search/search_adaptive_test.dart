import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/search/data/mock_ai_photo_search_repository.dart';
import 'package:gallery/features/search/presentation/cubit/search_cubit.dart';
import 'package:gallery/features/search/presentation/screens/search_screen.dart';

void main() {
  group(
    'SearchScreen & SuggestedPromptsView Adaptive Presentation (Rule 5.3)',
    () {
      late MockAiPhotoSearchRepository searchRepo;
      late SearchCubit searchCubit;
      late MockPhotoRepository photoRepo;
      late GalleryCubit galleryCubit;

      setUp(() {
        searchRepo = MockAiPhotoSearchRepository(
          simulatedDelay: Duration.zero,
          initialRecentSearches: ['dogs', 'beach'],
        );
        searchCubit = SearchCubit(searchRepository: searchRepo);
        photoRepo = MockPhotoRepository(simulatedDelay: Duration.zero);
        galleryCubit = GalleryCubit(photoRepository: photoRepo);
      });

      tearDown(() async {
        await searchCubit.close();
        await galleryCubit.close();
      });

      Widget createAdaptiveSearchApp({required TargetPlatform platform}) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<GalleryCubit>.value(value: galleryCubit),
            BlocProvider<SearchCubit>.value(value: searchCubit),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: platform),
            home: const SearchScreen(),
          ),
        );
      }

      testWidgets(
        'iOS target renders CupertinoSearchTextField, Cupertino pills, and Cupertino icons',
        (tester) async {
          await tester.pumpWidget(
            createAdaptiveSearchApp(platform: TargetPlatform.iOS),
          );
          await tester.pumpAndSettle();

          // 1. Cupertino search input and cancel button
          expect(find.byType(CupertinoSearchTextField), findsOneWidget);
          expect(
            find.widgetWithText(CupertinoButton, 'Cancel'),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.arrow_back), findsNothing);

          // 2. Cupertino prompt pills
          expect(find.byType(CupertinoButton), findsWidgets);
          expect(find.byType(ActionChip), findsNothing);

          // 3. Cupertino icons in prompts and recents
          expect(find.byIcon(CupertinoIcons.sparkles), findsWidgets);
          expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
          expect(find.byIcon(CupertinoIcons.arrow_up_left), findsWidgets);
        },
      );

      testWidgets(
        'Android target renders Material SearchBar, ActionChips, and Material icons',
        (tester) async {
          await tester.pumpWidget(
            createAdaptiveSearchApp(platform: TargetPlatform.android),
          );
          await tester.pumpAndSettle();

          // 1. Material search input and back icon button
          expect(find.byType(TextField), findsOneWidget);
          expect(find.byType(CupertinoSearchTextField), findsNothing);
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
          expect(find.text('Cancel'), findsNothing);

          // 2. Material 3 ActionChips
          expect(find.byType(ActionChip), findsWidgets);

          // 3. Material icons in prompts and recents
          expect(find.byIcon(Icons.auto_awesome), findsWidgets);
          expect(find.byIcon(Icons.history_rounded), findsOneWidget);
          expect(find.byIcon(Icons.north_west), findsWidgets);
        },
      );
    },
  );
}
