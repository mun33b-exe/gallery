import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';

/// Account Identity Card displaying user avatar initials, display name, and email.
/// Features a soft-orange circular avatar container, bold typography, and trailing chevron.
class ProfileIdentityCard extends StatelessWidget {
  final AuthUser? user;
  final VoidCallback? onTap;

  const ProfileIdentityCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.email.isNotEmpty == true
              ? user!.email.split('@').first
              : 'Muneeb');

    final email = user?.email.isNotEmpty == true
        ? user!.email
        : 'mtpicsdesigner@gmail.com';

    final initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'M';

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
          child: Row(
            children: [
              // Circular Initial Avatar
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1E5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF7A00),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing Chevron
              const AppSvgIcon(
                AppIcons.chevronRight,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
