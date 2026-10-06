import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';

/// Platform-adaptive dialog and feedback helpers.
class AdaptiveFeedback {
  AdaptiveFeedback._();

  /// Shows an alert dialog:
  /// - Android: Material AlertDialog
  /// - iOS: CupertinoAlertDialog
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colors = context.colors;

    if (isIOS) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surfaceSecondary,
          title: Text(title, style: TextStyle(color: colors.textPrimary)),
          content: Text(message, style: TextStyle(color: colors.textSecondary)),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              child: Text(buttonText, style: TextStyle(color: colors.accent)),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a notification message:
  /// - Android: Material SnackBar
  /// - iOS: Cupertino style alert or SnackBar
  static void showMessage(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final colors = context.colors;
    final snackBar = SnackBar(
      backgroundColor: isError ? colors.error : colors.surfaceElevated,
      content: Text(message, style: const TextStyle(color: AppPalette.white)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
