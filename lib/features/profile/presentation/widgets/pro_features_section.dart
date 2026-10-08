import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Upcoming Pro Features section and cards matching iOS design specification.
/// Features 3 preview cards (AI Search, RAW & HDR Export, Face & Event Clustering)
/// with interactive "Preview >" actions that launch detail modal sheets.
class ProFeaturesSection extends StatelessWidget {
  const ProFeaturesSection({super.key});

  void _showFeaturePreviewSheet(
    BuildContext context, {
    required String title,
    required String description,
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Icon + Badge
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: AppSvgIcon(iconPath, size: 26, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF7A00),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'This enhancement will run entirely on-device with zero remote tracking or mandatory subscriptions.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Got it button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Row(
          children: [
            AppSvgIcon(AppIcons.sparkles, size: 22, color: Color(0xFFFF7A00)),
            SizedBox(width: 10),
            Text(
              'Upcoming Pro Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        const Text(
          'Previewing future premium enhancements (Coming Soon — no store billing required).',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF94A3B8),
          ),
        ),

        const SizedBox(height: 16),

        // 1. Unlimited On-Device AI Search
        _buildFeatureCard(
          context: context,
          title: 'Unlimited On-Device AI Search',
          description: 'Instant semantic photo discovery powered by local on-device neural vectors with zero photo uploads.',
          iconPath: AppIcons.search,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEEF6FF),
        ),

        const SizedBox(height: 12),

        // 2. Lossless RAW & HDR Export
        _buildFeatureCard(
          context: context,
          title: 'Lossless RAW & HDR Export',
          description: 'Export full-fidelity DNG, Apple ProRAW, and UltraHDR photos without compression.',
          iconPath: AppIcons.images,
          iconColor: const Color(0xFFFF7A00),
          iconBgColor: const Color(0xFFFFF1E5),
        ),

        const SizedBox(height: 12),

        // 3. Semantic Face & Event Clustering
        _buildFeatureCard(
          context: context,
          title: 'Semantic Face & Event Clustering',
          description: 'Private on-device face clustering and automatic life-event album generation.',
          iconPath: AppIcons.usersRound,
          iconColor: const Color(0xFF159A68),
          iconBgColor: const Color(0xFFEEF9F3),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String iconPath,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Title + Preview Pill
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(iconPath, size: 22, color: iconColor),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Soft-orange "Preview >" Pill
              Semantics(
                label: 'Preview $title',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showFeaturePreviewSheet(
                        context,
                        title: title,
                        description: description,
                        iconPath: iconPath,
                        iconColor: iconColor,
                        iconBgColor: iconBgColor,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF7A00),
                            ),
                          ),
                          SizedBox(width: 4),
                          AppSvgIcon(
                            AppIcons.chevronRight,
                            size: 13,
                            color: Color(0xFFFF7A00),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Padding(
            padding: const EdgeInsets.only(left: 58),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
