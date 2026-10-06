import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';

/// Platform-adaptive text field:
/// - Android: Material 3 TextFormField with OutlineInputBorder
/// - iOS: Cupertino-styled text field with rounded container and subtle border
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const AdaptiveTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return _buildCupertinoField(context);
    }
    return _buildMaterialField(context);
  }

  Widget _buildMaterialField(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colors.textSecondary, size: AppSpacing.xl)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colors.accent, width: AppSpacing.xxs),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: BorderSide(color: colors.error, width: AppSpacing.xxs),
        ),
      ),
    );
  }

  Widget _buildCupertinoField(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                  color: fieldState.hasError ? colors.error : colors.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      color: colors.textSecondary,
                      size: AppSpacing.xl,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      enabled: enabled,
                      placeholder: hint,
                      placeholderStyle: TextStyle(color: colors.textMuted),
                      style: TextStyle(color: colors.textPrimary),
                      decoration: const BoxDecoration(),
                      onChanged: (val) {
                        fieldState.didChange(val);
                      },
                    ),
                  ),
                  ?suffixIcon,
                ],
              ),
            ),
            if (fieldState.hasError) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Text(
                  fieldState.errorText ?? '',
                  style: textTheme.bodySmall?.copyWith(color: colors.error),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
