import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/gallery/domain/category_model.dart';
import 'package:gallery/features/gallery/presentation/widgets/category_filter_bar.dart';

void main() {
  group('CategoryFilterBar Adaptive Presentation (Rule 5.3)', () {
    late List<CategoryModel> categories;
    late CategoryModel selectedCategory;

    setUp(() {
      categories = const [
        CategoryModel(
          id: 'all',
          title: 'All Photos',
          type: CategoryType.all,
          photoCount: 15,
        ),
        CategoryModel(
          id: 'favorites',
          title: 'Favorites',
          type: CategoryType.favorites,
          photoCount: 5,
        ),
      ];
      selectedCategory = categories.first;
    });

    Widget createAdaptiveBar({required TargetPlatform platform}) {
      return MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: CategoryFilterBar(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: (_) {},
          ),
        ),
      );
    }

    testWidgets('iOS target renders Cupertino buttons and Cupertino icons', (
      tester,
    ) async {
      await tester.pumpWidget(createAdaptiveBar(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoButton), findsWidgets);
      expect(find.byIcon(CupertinoIcons.photo_on_rectangle), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets(
      'Android target renders Material FilterChips and Material icons',
      (tester) async {
        await tester.pumpWidget(
          createAdaptiveBar(platform: TargetPlatform.android),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FilterChip), findsWidgets);
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
        expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
        expect(find.byType(CupertinoButton), findsNothing);
      },
    );
  });
}
