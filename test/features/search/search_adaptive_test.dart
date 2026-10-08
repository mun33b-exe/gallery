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
import 'package:gallery/features/search/presentation/widgets/suggested_prompts_view.dart';

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

      Widget createAdaptivePromptsApp({required TargetPlatform platform}) {
        return MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: SuggestedPromptsView(
              prompts: const ['dogs', 'beach'],
              onPromptSelected: (_) {},
            ),
          ),
        );
      }

      testWidgets(
        'SuggestedPromptsView renders CupertinoButton pills and Cupertino icons on iOS',
        (tester) async {
          await tester.pumpWidget(
            createAdaptivePromptsApp(platform: TargetPlatform.iOS),
          );
          await tester.pumpAndSettle();

          expect(find.byType(CupertinoButton), findsWidgets);
          expect(find.byType(ActionChip), findsNothing);
          expect(find.byIcon(CupertinoIcons.sparkles), findsOneWidget);
          expect(find.byIcon(CupertinoIcons.search), findsWidgets);
        },
      );

      testWidgets(
        'SuggestedPromptsView renders Material ActionChips and Material icons on Android',
        (tester) async {
          await tester.pumpWidget(
            createAdaptivePromptsApp(platform: TargetPlatform.android),
          );
          await tester.pumpAndSettle();

          expect(find.byType(ActionChip), findsWidgets);
          expect(find.byType(CupertinoButton), findsNothing);
          expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
          expect(find.byIcon(Icons.search_rounded), findsWidgets);
        },
      );

      testWidgets(
        'SearchScreen renders conversational layout safely across platforms',
        (tester) async {
          await tester.pumpWidget(
            createAdaptiveSearchApp(platform: TargetPlatform.iOS),
          );
          await tester.pumpAndSettle();

          expect(find.text('AI Search'), findsOneWidget);
          expect(find.text('Suggested Searches'), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
        },
      );
    },
  );
}
