import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService & Theme Persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getThemeId returns null initially when nothing is stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      expect(service.getThemeId(), isNull);
    });

    test(
      'setThemeId persists theme identifier and getThemeId retrieves it',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final service = PreferencesService(prefs);

        final success = await service.setThemeId('light');
        expect(success, isTrue);
        expect(service.getThemeId(), equals('light'));
      },
    );

    test('clearThemeId removes the saved theme identifier', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      await service.setThemeId('midnight');
      expect(service.getThemeId(), equals('midnight'));

      final cleared = await service.clearThemeId();
      expect(cleared, isTrue);
      expect(service.getThemeId(), isNull);
    });

    test(
      'ThemeCubit initializes with persisted theme from PreferencesService',
      () async {
        SharedPreferences.setMockInitialValues({
          PreferencesService.keyThemeId: 'light',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = PreferencesService(prefs);

        final cubit = ThemeCubit(preferencesService: service);
        expect(cubit.state.selectedTheme.id, equals('light'));

        await cubit.close();
      },
    );

    test('ThemeCubit persists theme ID when selectTheme is called', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      final cubit = ThemeCubit(preferencesService: service);
      expect(service.getThemeId(), isNull);

      final midnightTheme = AppThemes.getById('midnight');
      cubit.selectTheme(midnightTheme);
      await pumpEventQueue();

      expect(cubit.state.selectedTheme.id, equals('midnight'));
      expect(service.getThemeId(), equals('midnight'));

      await cubit.close();
    });
  });
}
