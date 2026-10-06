import 'package:equatable/equatable.dart';

import 'app_theme.dart';

/// State representing the currently selected theme.
class ThemeState extends Equatable {
  final AppThemeDefinition selectedTheme;

  const ThemeState({required this.selectedTheme});

  @override
  List<Object?> get props => [selectedTheme];
}
