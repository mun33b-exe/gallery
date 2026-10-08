import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/category_model.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/home_screen.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/category_filter_bar.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:gallery/features/search/data/mock_ai_photo_search_repository.dart';
import 'package:gallery/features/search/presentation/cubit/search_cubit.dart';
import 'package:gallery/features/search/presentation/screens/search_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Accessibility & Dynamic Type Tests (Phase 8)', () {
    late PhotoModel testPhoto;
    late MockPhotoRepository mockRepo;
    late ThemeCubit themeCubit;

    setUp(() {
      testPhoto = PhotoModel(
        id: 'a11y_1',
        title: 'Landscape.jpg',
        width: 1200,
        height: 800,
        createDateTime: DateTime(2025, 3, 1),
        isFavorite: true,
      );
      mockRepo = MockPhotoRepository(
        photos: [testPhoto],
        simulatedDelay: Duration.zero,
      );
      themeCubit = ThemeCubit();
    });

    tearDown(() async {
      await themeCubit.close();
    });

    testWidgets(
      'PhotoThumbnailTile exposes accessible Semantics with title and favorite status',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 150,
                height: 150,
                child: PhotoThumbnailTile(
                  photo: testPhoto,
                  photoRepository: mockRepo,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        final semanticsFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Photo: Landscape.jpg, Favorite' &&
              widget.properties.button == true,
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );

    testWidgets(
      'CategoryFilterBar chips expose button and selected Semantics',
      (tester) async {
        final categories = [
          const CategoryModel(
            id: 'all',
            title: 'All',
            type: CategoryType.all,
            photoCount: 42,
          ),
          const CategoryModel(
            id: 'favorites',
            title: 'Favorites',
            type: CategoryType.favorites,
            photoCount: 7,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryFilterBar(
                categories: categories,
                selectedCategory: categories.first,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify selected chip semantics
        final selectedSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'All, 42 photos' &&
              widget.properties.selected == true &&
              widget.properties.button == true,
        );
        expect(selectedSemantics, findsOneWidget);

        // Verify unselected chip semantics
        final unselectedSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Favorites, 7 photos' &&
              widget.properties.selected == false &&
              widget.properties.button == true,
        );
        expect(unselectedSemantics, findsOneWidget);
      },
    );

    testWidgets(
      'PhotoViewerScreen top bar controls have clear action Semantics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PhotoViewerScreen(
              args: PhotoViewerArgs(photos: [testPhoto], initialIndex: 0),
              photoRepository: mockRepo,
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Back',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics && w.properties.label == 'Remove from favorites',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Share photo',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Delete photo',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SearchScreen has accessible search field and button Semantics',
      (tester) async {
        final searchCubit = SearchCubit(
          searchRepository: MockAiPhotoSearchRepository(),
        );

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<SearchCubit>.value(value: searchCubit),
            ],
            child: const MaterialApp(home: SearchScreen()),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Search photos with natural language',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Back',
          ),
          findsOneWidget,
        );

        await searchCubit.close();
      },
    );

    testWidgets(
      'Dynamic Type: renders layouts safely at 200% font scaling without overflow',
      (tester) async {
        final categories = [
          const CategoryModel(
            id: 'all',
            title: 'All Photos',
            type: CategoryType.all,
            photoCount: 150,
          ),
          const CategoryModel(
            id: 'fav',
            title: 'Favorites',
            type: CategoryType.favorites,
            photoCount: 25,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 844),
                textScaler: TextScaler.linear(2.0),
              ),
              child: Scaffold(
                body: Column(
                  children: [
                    CategoryFilterBar(
                      categories: categories,
                      selectedCategory: categories.first,
                      onCategorySelected: (_) {},
                    ),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: PhotoThumbnailTile(
                        photo: testPhoto,
                        photoRepository: mockRepo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        // Expect no RenderFlex exception occurred at 2.0x font scaling
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Dynamic Type: HomeScreen renders safely at 200% font scaling without overflow',
      (tester) async {
        final galleryCubit = GalleryCubit(photoRepository: mockRepo);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<GalleryCubit>.value(value: galleryCubit),
            ],
            child: MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(390, 844),
                  textScaler: TextScaler.linear(2.0),
                ),
                child: const HomeScreen(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await galleryCubit.close();
      },
    );
  });
}
