import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:gallery/features/profile/domain/user_entitlement.dart';

/// Plan & Membership card matching iOS design specification.
/// Features a crown icon in a soft-orange circle, plan badge pill ("Free Plan" / "Pro Member"),
/// informative description, and trailing chevron affordance.
class MembershipCard extends StatelessWidget {
  final UserEntitlement entitlement;
  final VoidCallback? onTap;

  const MembershipCard({super.key, required this.entitlement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = entitlement.isPremium ? 'Pro Member' : 'Free Plan';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              // Top Row: Crown Icon + Title + Plan Badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1E5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const AppSvgIcon(
                      AppIcons.crown,
                      size: 22,
                      color: Color(0xFFFF7A00),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Text(
                      'Plan & Membership',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // Plan Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE96800),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Description & Trailing Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Your account is currently on the $badgeLabel. Local device media management, responsive filtering, and natural-language search preview are active.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AppSvgIcon(
                    AppIcons.chevronRight,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
