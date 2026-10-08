import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_svg_icon.dart';

/// Hero AI Gallery Assistant card matching the white-first design specification.
/// Contains the sparkles badge, title/subtitle, search bar trigger,
/// and 2x2 smart category shortcut pills.
class GalleryAssistantCard extends StatelessWidget {
  final VoidCallback? onPeopleTap;
  final VoidCallback? onPlacesTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onRecentlyAddedTap;

  const GalleryAssistantCard({
    super.key,
    this.onPeopleTap,
    this.onPlacesTap,
    this.onFavoritesTap,
    this.onRecentlyAddedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sparkles badge + Title + Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4E5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppSvgIcon(
                    AppIcons.sparkles,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Your personal Gallery Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Find photos, people, places and more using simple search.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Search Field & Filter Settings
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Search photos',
                  child: InkWell(
                    onTap: () => context.push('/search'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          AppSvgIcon(
                            AppIcons.search,
                            color: Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Search Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                button: true,
                label: 'Search filters and settings',
                child: InkWell(
                  onTap: () => context.push('/search'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: AppSvgIcon(
                        AppIcons.slidersHorizontal,
                        color: Color(0xFF111827),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2x2 Smart Shortcut Pills
          Row(
            children: [
              Expanded(
                child: _ShortcutPill(
                  label: 'People',
                  accentColor: const Color(0xFF22A06B),
                  bgColor: const Color(0xFFEAF8F0),
                  icon: AppIcons.usersRound,
                  onTap: onPeopleTap ?? () => context.push('/search'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutPill(
                  label: 'Places',
                  accentColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFF4E5),
                  icon: AppIcons.mapPin,
                  onTap: onPlacesTap ?? () => context.push('/search'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ShortcutPill(
                  label: 'Favorites',
                  accentColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEECEF),
                  icon: AppIcons.heart,
                  onTap: onFavoritesTap,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutPill(
                  label: 'Recently added',
                  accentColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF1EDFF),
                  icon: AppIcons.clock,
                  onTap: onRecentlyAddedTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutPill extends StatelessWidget {
  final String label;
  final Color accentColor;
  final Color bgColor;
  final String icon;
  final VoidCallback? onTap;

  const _ShortcutPill({
    required this.label,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                AppSvgIcon(icon, color: accentColor, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const AppSvgIcon(
                  AppIcons.chevronRight,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
