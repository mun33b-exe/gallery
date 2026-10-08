import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Top header for the redesigned Settings screen matching iOS design specification.
/// Features a circular back button (48–52px), bold title "Settings" (30–32px),
/// and a circular profile avatar button with an orange status dot.
class SettingsHeader extends StatelessWidget {
  final VoidCallback onBackTap;

  const SettingsHeader({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Circular Back Button
        Semantics(
          label: 'Back',
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBackTap,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPalette.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const AppSvgIcon(
                  AppIcons.chevronLeft,
                  size: 20,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Bold "Settings" Title
        const Expanded(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.8,
            ),
          ),
        ),
      ],
    );
  }
}
