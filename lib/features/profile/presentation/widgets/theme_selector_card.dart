import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Appearance & Themes section and unified card matching iOS design specification.
/// Features 3 selectable theme rows: Dark, Light, and Midnight Blue,
/// with the selected option highlighted in soft orange (#FFF1E5) and active radio ring.
class ThemeSelectorCard extends StatelessWidget {
  final String activeThemeId;
  final ValueChanged<String> onSelectTheme;

  const ThemeSelectorCard({
    super.key,
    required this.activeThemeId,
    required this.onSelectTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Row(
          children: [
            AppSvgIcon(AppIcons.sun, size: 22, color: Color(0xFFFF7A00)),
            SizedBox(width: 10),
            Text(
              'Appearance & Themes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Unified 24px Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildThemeRow(
                context: context,
                themeId: 'dark',
                title: 'Dark',
                subtitle: 'Dark mode',
                iconPath: AppIcons.moon,
                semanticLabel: 'Select dark theme',
              ),
              const SizedBox(height: 4),
              _buildThemeRow(
                context: context,
                themeId: 'light',
                title: 'Light',
                subtitle: 'Light mode',
                iconPath: AppIcons.sun,
                semanticLabel: 'Select light theme',
              ),
              const SizedBox(height: 4),
              _buildThemeRow(
                context: context,
                themeId: 'midnight',
                title: 'Midnight Blue',
                subtitle: 'Dark mode',
                iconPath: AppIcons.moonStar,
                semanticLabel: 'Select midnight blue theme',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeRow({
    required BuildContext context,
    required String themeId,
    required String title,
    required String subtitle,
    required String iconPath,
    required String semanticLabel,
  }) {
    final isSelected = activeThemeId == themeId;

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelectTheme(themeId),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF1E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Circular Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFE5CC)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    iconPath,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFFFF7A00)
                        : const Color(0xFF111827),
                  ),
                ),

                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom Radio Indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF7A00)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF7A00),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
