import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/preferences_service.dart';
import 'app_theme.dart';
import 'theme_state.dart';

/// Cubit responsible for managing the application's active theme.
class ThemeCubit extends Cubit<ThemeState> {
  final PreferencesService? _preferencesService;

  ThemeCubit({
    AppThemeDefinition? initialTheme,
    PreferencesService? preferencesService,
  }) : _preferencesService = preferencesService,
       super(
         ThemeState(
           selectedTheme:
               initialTheme ??
               (preferencesService?.getThemeId() != null
                   ? AppThemes.getById(preferencesService!.getThemeId()!)
                   : AppThemes.defaultTheme),
         ),
       );

  /// Selects a theme by its definition and persists it if PreferencesService is configured.
  void selectTheme(AppThemeDefinition theme) {
    if (state.selectedTheme.id != theme.id) {
      emit(ThemeState(selectedTheme: theme));
      _preferencesService?.setThemeId(theme.id);
    }
  }

  /// Selects a theme by its unique string identifier.
  void selectThemeById(String id) {
    final theme = AppThemes.getById(id);
    selectTheme(theme);
  }
}
