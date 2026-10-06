import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/app/theme/app_theme.dart';

/// Platform-adaptive suggested prompts widget.
/// Renders Material 3 ActionChips on Android and Cupertino pills on iOS (Rule 5.3).
class SuggestedPromptsView extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptSelected;
  final String title;

  const SuggestedPromptsView({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
    this.title = 'Suggested Searches',
  });

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              isIOS ? CupertinoIcons.sparkles : Icons.auto_awesome,
              size: 16,
              color: colors.accent,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: prompts.map((prompt) {
            if (isIOS) {
              return _buildCupertinoPrompt(context, prompt);
            } else {
              return _buildMaterialPrompt(context, prompt);
            }
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMaterialPrompt(BuildContext context, String prompt) {
    final colors = context.colors;

    return ActionChip(
      avatar: const Icon(
        Icons.search_rounded,
        size: 16,
        color: AppPalette.slate400,
      ),
      label: Text(
        prompt,
        style: TextStyle(fontSize: 13, color: colors.textPrimary),
      ),
      backgroundColor: colors.surfaceSecondary,
      side: BorderSide(color: colors.border),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusFull),
      onPressed: () => onPromptSelected(prompt),
    );
  }

  Widget _buildCupertinoPrompt(BuildContext context, String prompt) {
    final colors = context.colors;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      minimumSize: Size.zero,
      borderRadius: AppSpacing.borderRadiusFull,
      color: colors.surfaceElevated.withValues(alpha: 0.8),
      onPressed: () => onPromptSelected(prompt),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 13,
            color: AppPalette.slate400,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            prompt,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
