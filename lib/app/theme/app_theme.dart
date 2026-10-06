import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Custom theme extension for clean access to semantic colors across all screens.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final SemanticColors colors;

  const AppThemeExtension({required this.colors});

  @override
  ThemeExtension<AppThemeExtension> copyWith({SemanticColors? colors}) {
    return AppThemeExtension(colors: colors ?? this.colors);
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return this;
  }
}

/// Extensible model defining a supported application theme.
class AppThemeDefinition extends Equatable {
  final String id;
  final String displayName;
  final Brightness brightness;
  final ThemeData themeData;
  final SemanticColors semanticColors;

  const AppThemeDefinition({
    required this.id,
    required this.displayName,
    required this.brightness,
    required this.themeData,
    required this.semanticColors,
  });

  @override
  List<Object?> get props => [id, displayName, brightness];
}

/// Central registry of available application themes.
/// Adding a theme here automatically surfaces it to the theme selection system.
class AppThemes {
  AppThemes._();

  static const String darkThemeId = 'dark';
  static const String lightThemeId = 'light';
  static const String midnightThemeId = 'midnight';

  static final List<AppThemeDefinition> available = [
    _buildDarkTheme(),
    _buildLightTheme(),
    _buildMidnightTheme(),
  ];

  static AppThemeDefinition get defaultTheme => available.first;

  static AppThemeDefinition getById(String id) {
    return available.firstWhere(
      (theme) => theme.id == id,
      orElse: () => defaultTheme,
    );
  }

  static AppThemeDefinition _buildDarkTheme() {
    const semantic = SemanticColors.dark;
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: semantic.accent,
      onPrimary: AppPalette.white,
      secondary: AppPalette.indigo400,
      onSecondary: AppPalette.white,
      error: semantic.error,
      onError: AppPalette.white,
      surface: semantic.surfacePrimary,
      onSurface: semantic.textPrimary,
      surfaceContainerHighest: semantic.surfaceElevated,
      outline: semantic.border,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantic.surfacePrimary,
      cardColor: semantic.surfaceSecondary,
      dividerColor: semantic.border,
      textTheme: AppTextStyles.createTextTheme(
        semantic.textPrimary,
        semantic.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.surfacePrimary,
        foregroundColor: semantic.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: semantic.surfaceSecondary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppPalette.slate800),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      extensions: const [AppThemeExtension(colors: semantic)],
    );

    return AppThemeDefinition(
      id: darkThemeId,
      displayName: 'Dark',
      brightness: Brightness.dark,
      themeData: themeData,
      semanticColors: semantic,
    );
  }

  static AppThemeDefinition _buildLightTheme() {
    const semantic = SemanticColors.light;
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: semantic.accent,
      onPrimary: AppPalette.white,
      secondary: AppPalette.indigo700,
      onSecondary: AppPalette.white,
      error: semantic.error,
      onError: AppPalette.white,
      surface: semantic.surfacePrimary,
      onSurface: semantic.textPrimary,
      surfaceContainerHighest: semantic.surfaceElevated,
      outline: semantic.border,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantic.surfacePrimary,
      cardColor: semantic.surfaceSecondary,
      dividerColor: semantic.border,
      textTheme: AppTextStyles.createTextTheme(
        semantic.textPrimary,
        semantic.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.surfacePrimary,
        foregroundColor: semantic.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: semantic.surfaceSecondary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppPalette.slate200),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      extensions: const [AppThemeExtension(colors: semantic)],
    );

    return AppThemeDefinition(
      id: lightThemeId,
      displayName: 'Light',
      brightness: Brightness.light,
      themeData: themeData,
      semanticColors: semantic,
    );
  }

  static AppThemeDefinition _buildMidnightTheme() {
    const semantic = SemanticColors.midnight;
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: semantic.accent,
      onPrimary: AppPalette.midnightNavy,
      secondary: AppPalette.midnightCyan,
      onSecondary: AppPalette.midnightNavy,
      error: semantic.error,
      onError: AppPalette.white,
      surface: semantic.surfacePrimary,
      onSurface: semantic.textPrimary,
      surfaceContainerHighest: semantic.surfaceElevated,
      outline: semantic.border,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantic.surfacePrimary,
      cardColor: semantic.surfaceSecondary,
      dividerColor: semantic.border,
      textTheme: AppTextStyles.createTextTheme(
        semantic.textPrimary,
        semantic.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: semantic.surfacePrimary,
        foregroundColor: semantic.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppPalette.midnightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF283A61)),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      extensions: const [AppThemeExtension(colors: semantic)],
    );

    return AppThemeDefinition(
      id: midnightThemeId,
      displayName: 'Midnight Blue',
      brightness: Brightness.dark,
      themeData: themeData,
      semanticColors: semantic,
    );
  }
}

/// Helper extension to easily access semantic colors on context.
extension AppThemeContext on BuildContext {
  SemanticColors get colors =>
      Theme.of(this).extension<AppThemeExtension>()?.colors ??
      SemanticColors.dark;
}
