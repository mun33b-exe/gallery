import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Horizontally scrollable recent search query chips with clear action.
class RecentSearchesChips extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onSelectRecent;
  final VoidCallback onClear;

  const RecentSearchesChips({
    super.key,
    required this.recentSearches,
    required this.onSelectRecent,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                AppSvgIcon(AppIcons.clock, color: Color(0xFF6B7280), size: 18),
                SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF7A00),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Horizontally Scrollable Query Chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentSearches.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final query = recentSearches[index];
              return Semantics(
                button: true,
                label: 'Search for $query',
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => onSelectRecent(query),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppSvgIcon(
                            AppIcons.search,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            query,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
