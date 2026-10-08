import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

class SuggestedSearchItem {
  final String title;
  final String icon;
  final Color bgColor;
  final Color iconColor;

  const SuggestedSearchItem({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

/// 2-Column responsive grid displaying pastel shortcut cards for popular AI searches.
class SuggestedSearchesGrid extends StatelessWidget {
  final ValueChanged<String> onSearchTap;
  final VoidCallback? onSeeAllTap;

  const SuggestedSearchesGrid({
    super.key,
    required this.onSearchTap,
    this.onSeeAllTap,
  });

  static const List<SuggestedSearchItem> kDefaultItems = [
    SuggestedSearchItem(
      title: 'Show photos of dogs',
      icon: AppIcons.image,
      bgColor: Color(0xFFEEF6FF),
      iconColor: Color(0xFF3B82F6),
    ),
    SuggestedSearchItem(
      title: 'Find photos from my birthday',
      icon: AppIcons.heart,
      bgColor: Color(0xFFFFF0F1),
      iconColor: Color(0xFFEF4444),
    ),
    SuggestedSearchItem(
      title: 'Show beach photos',
      icon: AppIcons.compass,
      bgColor: Color(0xFFFFF8E8),
      iconColor: Color(0xFFF59E0B),
    ),
    SuggestedSearchItem(
      title: 'Find photos with cars',
      icon: AppIcons.slidersHorizontal,
      bgColor: Color(0xFFEEF9F3),
      iconColor: Color(0xFF10B981),
    ),
    SuggestedSearchItem(
      title: 'Hilly areas',
      icon: AppIcons.mapPin,
      bgColor: Color(0xFFFFF1E5),
      iconColor: Color(0xFFFF7A00),
    ),
    SuggestedSearchItem(
      title: 'Show payment receipts',
      icon: AppIcons.fileText,
      bgColor: Color(0xFFEEF6FF),
      iconColor: Color(0xFF3B82F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Suggested Searches',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.4,
              ),
            ),
            InkWell(
              onTap: onSeeAllTap ?? () => onSearchTap('Show photos of dogs'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(width: 2),
                    AppSvgIcon(
                      AppIcons.chevronRight,
                      color: Color(0xFF6B7280),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // 2-Column Responsive Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - AppSpacing.sm) / 2;

            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: kDefaultItems.map((item) {
                return SizedBox(
                  width: cardWidth,
                  height: 78,
                  child: Semantics(
                    button: true,
                    label: item.title,
                    child: Material(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => onSearchTap(item.title),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: AppSvgIcon(
                                    item.icon,
                                    color: item.iconColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const AppSvgIcon(
                                AppIcons.chevronRight,
                                color: Color(0xFF9CA3AF),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
