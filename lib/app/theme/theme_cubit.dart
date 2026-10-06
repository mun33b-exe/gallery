import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'theme_state.dart';

/// Cubit responsible for managing the application's active theme.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({AppThemeDefinition? initialTheme})
    : super(ThemeState(selectedTheme: initialTheme ?? AppThemes.defaultTheme));

  /// Selects a theme by its definition.
  void selectTheme(AppThemeDefinition theme) {
    if (state.selectedTheme.id != theme.id) {
      emit(ThemeState(selectedTheme: theme));
    }
  }

  /// Selects a theme by its unique string identifier.
  void selectThemeById(String id) {
    final theme = AppThemes.getById(id);
    selectTheme(theme);
  }
}
