import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/category_model.dart';

/// Platform-adaptive category filter bar.
/// Renders Material 3 FilterChips on Android and Cupertino pills on iOS (Rule 5.3).
class CategoryFilterBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel selectedCategory;
  final ValueChanged<CategoryModel> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategory.id;

          if (isIOS) {
            return _buildCupertinoChip(context, category, isSelected);
          } else {
            return _buildMaterialChip(context, category, isSelected);
          }
        },
      ),
    );
  }

  Widget _buildMaterialChip(
    BuildContext context,
    CategoryModel category,
    bool isSelected,
  ) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${category.title}, ${category.photoCount} photos',
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          _getMaterialIcon(category.type),
          size: 16,
          color: isSelected ? colors.surfacePrimary : colors.textSecondary,
        ),
        label: Text(
          '${category.title} (${category.photoCount})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colors.surfacePrimary : colors.textPrimary,
          ),
        ),
        selectedColor: colors.accent,
        backgroundColor: colors.surfaceSecondary,
        side: BorderSide(
          color: isSelected ? colors.accent : colors.border,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        onSelected: (_) => onCategorySelected(category),
      ),
    );
  }

  Widget _buildCupertinoChip(
    BuildContext context,
    CategoryModel category,
    bool isSelected,
  ) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${category.title}, ${category.photoCount} photos',
      child: Center(
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          borderRadius: AppSpacing.borderRadiusFull,
          color: isSelected
              ? colors.accent
              : colors.surfaceElevated.withValues(alpha: 0.8),
          onPressed: () => onCategorySelected(category),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCupertinoIcon(category.type),
                size: 14,
                color: isSelected ? AppPalette.white : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${category.title} (${category.photoCount})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppPalette.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(CategoryType type) {
    switch (type) {
      case CategoryType.all:
        return Icons.photo_library_outlined;
      case CategoryType.favorites:
        return Icons.favorite_rounded;
      case CategoryType.recent:
        return Icons.access_time_rounded;
      case CategoryType.screenshots:
        return Icons.screenshot_outlined;
      case CategoryType.camera:
        return Icons.camera_alt_outlined;
    }
  }

  IconData _getCupertinoIcon(CategoryType type) {
    switch (type) {
      case CategoryType.all:
        return CupertinoIcons.photo_on_rectangle;
      case CategoryType.favorites:
        return CupertinoIcons.heart_fill;
      case CategoryType.recent:
        return CupertinoIcons.clock;
      case CategoryType.screenshots:
        return CupertinoIcons.device_phone_portrait;
      case CategoryType.camera:
        return CupertinoIcons.camera;
    }
  }
}
