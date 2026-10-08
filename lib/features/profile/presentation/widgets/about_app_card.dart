import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// About Application section matching iOS design specification.
/// Displays structured system metadata rows with circular icons and right-aligned semibold values:
/// App Version, Target Platforms, Storage Engine, and Backend Auth.
class AboutAppCard extends StatelessWidget {
  const AboutAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Row(
          children: [
            AppSvgIcon(AppIcons.info, size: 22, color: Color(0xFFFF7A00)),
            SizedBox(width: 10),
            Text(
              'About Application',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              _buildMetadataRow(
                iconPath: AppIcons.packageIcon,
                label: 'App Version',
                value: '1.0.0 (Build 1)',
              ),
              const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),
              _buildMetadataRow(
                iconPath: AppIcons.smartphone,
                label: 'Target Platforms',
                value: 'Android & iOS',
              ),
              const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),
              _buildMetadataRow(
                iconPath: AppIcons.database,
                label: 'Storage Engine',
                value: 'On-Device PhotoManager',
              ),
              const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),
              _buildMetadataRow(
                iconPath: AppIcons.codeXml,
                label: 'Backend Auth',
                value: 'Supabase Auth',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Circular Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppSvgIcon(
              iconPath,
              size: 20,
              color: const Color(0xFF111827),
            ),
          ),

          const SizedBox(width: 14),

          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
