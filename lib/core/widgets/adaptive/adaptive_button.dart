import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import 'adaptive_progress_indicator.dart';

enum AdaptiveButtonType { primary, secondary, text }

/// Platform-adaptive button:
/// - Android: Material 3 ElevatedButton / OutlinedButton / TextButton
/// - iOS: CupertinoButton.filled / CupertinoButton (outlined/plain)
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AdaptiveButtonType type;
  final IconData? icon;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AdaptiveButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colors = context.colors;

    if (isIOS) {
      return _buildCupertinoButton(context, colors);
    }
    return _buildMaterialButton(context, colors);
  }

  Widget _buildMaterialButton(BuildContext context, SemanticColors colors) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child = isLoading
        ? const AdaptiveProgressIndicator(size: AppSpacing.lg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.lg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(text),
            ],
          );

    switch (type) {
      case AdaptiveButtonType.primary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: AppPalette.white,
            disabledBackgroundColor: colors.surfaceElevated,
            disabledForegroundColor: colors.textMuted,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
      case AdaptiveButtonType.secondary:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.border),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
      case AdaptiveButtonType.text:
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: colors.accent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
    }
  }

  Widget _buildCupertinoButton(BuildContext context, SemanticColors colors) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child = isLoading
        ? const AdaptiveProgressIndicator(size: AppSpacing.lg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.lg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: type == AdaptiveButtonType.primary
                      ? AppPalette.white
                      : colors.accent,
                ),
              ),
            ],
          );

    switch (type) {
      case AdaptiveButtonType.primary:
        return CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          borderRadius: AppSpacing.borderRadiusMd,
          onPressed: effectiveOnPressed,
          child: child,
        );
      case AdaptiveButtonType.secondary:
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: colors.border),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            borderRadius: AppSpacing.borderRadiusMd,
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
      case AdaptiveButtonType.text:
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
    }
  }
}
