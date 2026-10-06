import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_button.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_state.dart';
import 'package:go_router/go_router.dart';

/// Platform-adaptive Application Settings screen (Rule 5.3).
/// Includes persistent theme selection, photo library permissions entry point,
/// on-device privacy guarantee banner, and application version metadata.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

    final appBar = isIOS
        ? CupertinoNavigationBar(
            backgroundColor: colors.surfacePrimary,
            border: Border(bottom: BorderSide(color: colors.border)),
            middle: Text(
              'Settings',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/profile'),
              child: Icon(
                CupertinoIcons.person_crop_circle,
                color: colors.textSecondary,
                size: AppSpacing.xl,
              ),
            ),
          )
        : AppBar(
            title: Text(
              'Settings',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: colors.textSecondary,
                ),
                tooltip: 'Profile',
                onPressed: () => context.push('/profile'),
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
              // 1. Account & Profile Shortcut
              _buildProfileShortcut(context, isIOS),
              const SizedBox(height: AppSpacing.xl),

              // 2. Theme Selection Section
              _buildSectionTitle(context, 'Appearance & Themes', isIOS),
              const SizedBox(height: AppSpacing.sm),
              _buildThemeSelector(context, isIOS),
              const SizedBox(height: AppSpacing.xl),

              // 3. Privacy & Media Permissions
              _buildSectionTitle(context, 'Privacy & Permissions', isIOS),
              const SizedBox(height: AppSpacing.sm),
              _buildPrivacyBanner(context, isIOS),
              const SizedBox(height: AppSpacing.sm),
              _buildPermissionsDiagnosticTile(context, isIOS),
              const SizedBox(height: AppSpacing.xl),

              // 4. App Information & About
              _buildSectionTitle(context, 'About Application', isIOS),
              const SizedBox(height: AppSpacing.sm),
              _buildAppInfoSection(context, isIOS),
              const SizedBox(height: AppSpacing.xl),

              // 5. Sign Out Button
              Center(
                child: AdaptiveButton(
                  text: 'Sign Out',
                  type: AdaptiveButtonType.secondary,
                  onPressed: () => _confirmSignOut(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileShortcut(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: AppSpacing.borderRadiusLg,
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.accent.withValues(alpha: 0.15),
              foregroundColor: colors.accent,
              radius: 20,
              child: Icon(
                isIOS ? CupertinoIcons.person_fill : Icons.person_rounded,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Account & Entitlements',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Manage membership tier, view profile, and sign out',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isIOS
                  ? CupertinoIcons.chevron_forward
                  : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final activeTheme = context.watch<ThemeCubit>().state.selectedTheme;

    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: colors.border),
        ),
        child: CupertinoListSection.insetGrouped(
          margin: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          children: AppThemes.available.map((theme) {
            final isSelected = theme.id == activeTheme.id;
            return CupertinoListTile(
              title: Text(
                theme.displayName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                theme.brightness == Brightness.dark
                    ? 'Dark mode'
                    : 'Light mode',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              trailing: isSelected
                  ? Icon(
                      CupertinoIcons.checkmark_alt,
                      color: colors.accent,
                      size: 20,
                    )
                  : null,
              onTap: () => context.read<ThemeCubit>().selectTheme(theme),
            );
          }).toList(),
        ),
      );
    } else {
      return Material(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: colors.border),
          ),
          child: RadioGroup<String>(
            groupValue: activeTheme.id,
            onChanged: (themeId) {
              if (themeId != null) {
                context.read<ThemeCubit>().selectThemeById(themeId);
              }
            },
            child: Column(
              children: AppThemes.available.map((theme) {
                final isSelected = theme.id == activeTheme.id;
                return RadioListTile<String>(
                  value: theme.id,
                  activeColor: colors.accent,
                  title: Text(
                    theme.displayName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    theme.brightness == Brightness.dark
                        ? 'Dark palette'
                        : 'Light palette',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPrivacyBanner(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isIOS ? CupertinoIcons.shield_fill : Icons.verified_user_rounded,
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local-Only Privacy Guarantee',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Your photos and media files never leave your device. All thumbnails, albums, and AI search indices are stored locally and are never uploaded to any remote server.',
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

  Widget _buildPermissionsDiagnosticTile(BuildContext context, bool isIOS) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final galleryState = context.watch<GalleryCubit?>()?.state;

    final isLimited =
        galleryState is GalleryLoaded && galleryState.isLimitedPermission;
    final statusText = isLimited ? 'Limited Access' : 'Access Granted';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            isIOS
                ? CupertinoIcons.photo_on_rectangle
                : Icons.photo_library_outlined,
            color: colors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo Library Permission',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  statusText,
                  style: textTheme.bodySmall?.copyWith(
                    color: isLimited ? colors.accent : AppPalette.slate400,
                  ),
                ),
              ],
            ),
          ),
          if (isIOS)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              onPressed: () => context.read<GalleryCubit>().openAppSettings(),
              child: Text(
                'Manage',
                style: TextStyle(color: colors.accent, fontSize: 14),
              ),
            )
          else
            TextButton(
              onPressed: () => context.read<GalleryCubit>().openAppSettings(),
              child: Text(
                'Manage',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, bool isIOS) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'App Version', '1.0.0 (Build 1)'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow(context, 'Target Platforms', 'Android & iOS'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow(context, 'Storage Engine', 'On-Device PhotoManager'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow(context, 'Backend Auth', 'Supabase Auth'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
