import 'package:flutter/material.dart';

/// Raw palette tokens for the Gallery application.
class AppPalette {
  AppPalette._();

  // Neutral grays / slates
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Pure darks and lights
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Primary brand indigos
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);

  // Midnight blue accents
  static const Color midnightNavy = Color(0xFF0B132B);
  static const Color midnightSurface = Color(0xFF1C2541);
  static const Color midnightCyan = Color(0xFF5BC0BE);

  // Semantic feedback
  static const Color emerald500 = Color(0xFF10B981);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color red500 = Color(0xFFEF4444);
}

/// Semantic color roles available per theme.
class SemanticColors {
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color accent;
  final Color error;
  final Color success;

  const SemanticColors({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.accent,
    required this.error,
    required this.success,
  });

  // Dark theme palette
  static const SemanticColors dark = SemanticColors(
    surfacePrimary: AppPalette.slate950,
    surfaceSecondary: AppPalette.slate900,
    surfaceElevated: AppPalette.slate800,
    textPrimary: AppPalette.slate50,
    textSecondary: AppPalette.slate300,
    textMuted: AppPalette.slate500,
    border: AppPalette.slate800,
    accent: AppPalette.indigo500,
    error: AppPalette.rose500,
    success: AppPalette.emerald500,
  );

  // Light theme palette
  static const SemanticColors light = SemanticColors(
    surfacePrimary: AppPalette.white,
    surfaceSecondary: AppPalette.slate50,
    surfaceElevated: AppPalette.slate100,
    textPrimary: AppPalette.slate900,
    textSecondary: AppPalette.slate700,
    textMuted: AppPalette.slate400,
    border: AppPalette.slate200,
    accent: AppPalette.indigo600,
    error: AppPalette.red500,
    success: AppPalette.emerald500,
  );

  // Midnight Blue theme palette
  static const SemanticColors midnight = SemanticColors(
    surfacePrimary: AppPalette.midnightNavy,
    surfaceSecondary: AppPalette.midnightSurface,
    surfaceElevated: Color(0xFF263359),
    textPrimary: AppPalette.white,
    textSecondary: Color(0xFFD4E0F0),
    textMuted: Color(0xFF8798B5),
    border: Color(0xFF283A61),
    accent: AppPalette.midnightCyan,
    error: AppPalette.rose500,
    success: AppPalette.emerald500,
  );
}
