import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';

void main() {
  group('Theme Architecture & Registry', () {
    test('AppThemes registry has at least two unique themes', () {
      expect(AppThemes.available.length, greaterThanOrEqualTo(2));

      final ids = AppThemes.available.map((t) => t.id).toSet();
      expect(
        ids.length,
        equals(AppThemes.available.length),
        reason: 'Theme IDs must be unique',
      );

      for (final theme in AppThemes.available) {
        expect(theme.displayName.isNotEmpty, isTrue);
        expect(theme.themeData, isNotNull);
        expect(theme.semanticColors, isNotNull);
      }
    });

    test(
      'AppThemes.getById retrieves the correct theme or falls back to default',
      () {
        final darkTheme = AppThemes.getById(AppThemes.darkThemeId);
        expect(darkTheme.id, equals(AppThemes.darkThemeId));

        final fallback = AppThemes.getById('non_existent_id');
        expect(fallback.id, equals(AppThemes.defaultTheme.id));
      },
    );
  });

  group('ThemeCubit State Transitions', () {
    test('initial state defaults to AppThemes.defaultTheme', () {
      final cubit = ThemeCubit();
      expect(cubit.state.selectedTheme.id, equals(AppThemes.defaultTheme.id));
      cubit.close();
    });

    test('selectTheme emits new ThemeState with selected theme', () {
      final cubit = ThemeCubit();
      final lightTheme = AppThemes.getById(AppThemes.lightThemeId);

      expectLater(
        cubit.stream,
        emits(
          predicate<dynamic>(
            (state) => state.selectedTheme.id == lightTheme.id,
          ),
        ),
      );

      cubit.selectTheme(lightTheme);
      expect(cubit.state.selectedTheme.id, equals(lightTheme.id));
      cubit.close();
    });

    test('selectThemeById changes theme appropriately', () {
      final cubit = ThemeCubit();
      final midnightTheme = AppThemes.getById(AppThemes.midnightThemeId);

      cubit.selectThemeById(midnightTheme.id);
      expect(cubit.state.selectedTheme.id, equals(midnightTheme.id));
      cubit.close();
    });
  });
}
