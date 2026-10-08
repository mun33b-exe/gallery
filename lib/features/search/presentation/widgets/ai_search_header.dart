import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:go_router/go_router.dart';

/// Top header for the AI Gallery Search screen matching design specifications.
/// Contains a circular light-gray back button, bold "AI Search" title, and subtitle.
class AiSearchHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const AiSearchHeader({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular back button
        Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap:
                onBackTap ??
                () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
            borderRadius: BorderRadius.circular(26),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppSvgIcon(
                  AppIcons.chevronRight,
                  color: Color(0xFF111827),
                  size: 22,
                  quarterTurns: 2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Title & Subtitle
        const Text(
          'AI Search',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Find photos, people, places and more',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
