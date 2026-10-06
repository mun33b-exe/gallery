import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';

/// Platform-adaptive progress indicator:
/// - Android: Material CircularProgressIndicator
/// - iOS: CupertinoActivityIndicator
class AdaptiveProgressIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AdaptiveProgressIndicator({
    super.key,
    this.size = AppSpacing.xl,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final effectiveColor = color ?? context.colors.accent;

    if (isIOS) {
      return CupertinoActivityIndicator(
        radius: size / 2,
        color: effectiveColor,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: AppSpacing.xs,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}
