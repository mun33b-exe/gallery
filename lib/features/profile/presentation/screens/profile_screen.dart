import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_button.dart';
import 'package:gallery/features/auth/domain/auth_user.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_state.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_entitlement.dart';

/// Platform-adaptive User Profile screen.
/// Displays avatar, user metadata, account entitlement tier,
/// preview premium cards (Section 9), and guarded sign-out.
class ProfileScreen extends StatelessWidget {
  final UserEntitlement entitlement;

  const ProfileScreen({super.key, this.entitlement = UserEntitlement.freeTier});

  Future<void> _confirmSignOut(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colors = context.colors;

    if (isIOS) {
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Sign Out'),
          content: const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text('Are you sure you want to sign out of your account?'),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await context.read<AuthCubit>().logout();
      }
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surfaceElevated,
          title: Text('Sign Out', style: TextStyle(color: colors.textPrimary)),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Sign Out', style: TextStyle(color: colors.error)),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await context.read<AuthCubit>().logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    final appBar = isIOS
        ? CupertinoNavigationBar(
            backgroundColor: colors.surfacePrimary,
            border: Border(bottom: BorderSide(color: colors.border)),
            middle: Text(
              'Profile',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/settings'),
              child: Icon(
                CupertinoIcons.settings,
                color: colors.textSecondary,
                size: AppSpacing.xl,
              ),
            ),
          )
        : AppBar(
            title: Text(
              'Profile',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colors.textSecondary,
                ),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ],
          );

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: isIOS
          ? appBar as ObstructingPreferredSizeWidget
          : appBar as PreferredSizeWidget,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Card
              if (user != null)
                _buildUserProfileHeader(context, user, isIOS)
              else
                _buildGuestHeader(context),

              const SizedBox(height: AppSpacing.xl),

              // Account & Entitlement Status
              _buildEntitlementSection(context, isIOS),

              const SizedBox(height: AppSpacing.xl),

              // Premium Feature Previews (Section 9 - Zero payment code)
              _buildPremiumFeaturePreviewSection(context, isIOS),

              const SizedBox(height: AppSpacing.xxl),

              // Sign Out Button
              if (user != null)
                Center(
                  child: AdaptiveButton(
                    text: 'Sign Out',
                    type: AdaptiveButtonType.secondary,
                    onPressed: () => _confirmSignOut(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(
    BuildContext context,
    AuthUser user,
    bool isIOS,
  ) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final initial = user.displayName.isNotEmpty
        ? user.displayName.substring(0, 1).toUpperCase()
        : (user.email.isNotEmpty
              ? user.email.substring(0, 1).toUpperCase()
              : 'U');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.accent,
            foregroundColor: AppPalette.white,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isNotEmpty
                      ? user.displayName
                      : 'Gallery User',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  user.email,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.surfaceElevated,
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Session',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Sign in to access your profile',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntitlementSection(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan & Membership',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: entitlement.isPremium
                      ? colors.accent.withValues(alpha: 0.2)
                      : colors.surfaceElevated,
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(
                    color: entitlement.isPremium
                        ? colors.accent
                        : colors.border,
                  ),
                ),
                child: Text(
                  entitlement.statusDescription,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: entitlement.isPremium
                        ? colors.accent
                        : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your account is currently on the ${entitlement.statusDescription}. Local device media management, responsive filtering, and natural-language search preview are active.',
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturePreviewSection(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isIOS ? CupertinoIcons.sparkles : Icons.auto_awesome,
              size: 18,
              color: colors.accent,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Upcoming Pro Features',
              style: textTheme.labelLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Previewing future premium enhancements (Coming Soon — no store billing required).',
          style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPreviewCard(
          context,
          icon: isIOS
              ? CupertinoIcons.search_circle_fill
              : Icons.saved_search_rounded,
          title: 'Unlimited On-Device AI Search',
          subtitle: 'Instant semantic photo discovery powered by local on-device neural vectors with zero photo uploads.',
          isIOS: isIOS,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPreviewCard(
          context,
          icon: isIOS
              ? CupertinoIcons.photo_fill_on_rectangle_fill
              : Icons.raw_on_rounded,
          title: 'Lossless RAW & HDR Export',
          subtitle: 'Export full-fidelity DNG, Apple ProRAW, and UltraHDR photos without compression.',
          isIOS: isIOS,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPreviewCard(
          context,
          icon: isIOS
              ? CupertinoIcons.person_crop_circle_badge_checkmark
              : Icons.face_retouching_natural_rounded,
          title: 'Semantic Face & Event Clustering',
          subtitle: 'Private on-device face clustering and automatic life-event album generation.',
          isIOS: isIOS,
        ),
      ],
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isIOS,
  }) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.accent, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
