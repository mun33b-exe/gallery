import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/responsive/responsive.dart';
import '../../core/widgets/adaptive/adaptive_button.dart';
import '../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

/// AppShell serves as the foundation preview shell for Phase 1 & 2.
/// Demonstrates responsive layout calculations, dynamic multi-theme switching,
/// authenticated user session handling, and standardized design tokens.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final deviceType = Responsive.deviceType(context);
    final columns = Responsive.galleryColumns(context);
    final screenWidth = Responsive.screenWidth(context);
    final authState = context.watch<AuthCubit?>()?.state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        title: Text(
          'AI Gallery Foundation',
          style: textTheme.headlineMedium?.copyWith(color: colors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  '${deviceType.name.toUpperCase()} (${screenWidth.toInt()}px, ${columns}col)',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) ...[
                _buildUserSessionCard(context, user),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Theme Switcher Section
              _buildSectionHeader(
                context,
                title: 'Theme Selector',
                subtitle:
                    'Dynamic theme engine supporting all registered themes',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildThemeSelector(context),
              const SizedBox(height: AppSpacing.xl),

              // Responsive Grid Section
              _buildSectionHeader(
                context,
                title: 'Responsive Grid System',
                subtitle:
                    'Adapts columns ($columns) based on centralized responsive.dart',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildResponsiveGrid(context, columns: columns),
              const SizedBox(height: AppSpacing.xl),

              // Shared UI Design Components Showcase
              _buildSectionHeader(
                context,
                title: 'Design System & State Components',
                subtitle: 'Pre-built button, loading, empty, and error representations',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildComponentShowcase(context),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineLarge?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final colors = context.colors;
    final currentThemeId = context.watch<ThemeCubit>().state.selectedTheme.id;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppThemes.available.map((theme) {
        final isSelected = theme.id == currentThemeId;
        return InkWell(
          borderRadius: AppSpacing.borderRadiusMd,
          onTap: () {
            context.read<ThemeCubit>().selectTheme(theme);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colors.accent : colors.surfaceSecondary,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isSelected ? colors.accent : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: AppSpacing.lg,
                  color: isSelected ? AppPalette.white : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  theme.displayName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? AppPalette.white : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, {required int columns}) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: columns * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      color: colors.accent,
                      size: AppSpacing.xxl,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Item ${index + 1}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComponentShowcase(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Action Controls Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Button & Action Tokens',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AdaptiveButton(
                      text: 'Primary Action',
                      type: AdaptiveButtonType.primary,
                      onPressed: () {},
                    ),
                    AdaptiveButton(
                      text: 'Secondary Action',
                      type: AdaptiveButtonType.secondary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // State Feedback Cards
        Row(
          children: [
            // Loading State Card
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      const AdaptiveProgressIndicator(size: AppSpacing.xxl),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Loading state',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Empty State Card
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: AppSpacing.xxxl,
                        color: colors.textMuted,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Empty state',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Error State Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colors.error,
                  size: AppSpacing.xl,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Feedback Pattern',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.error,
                        ),
                      ),
                      Text(
                        'Centralized semantic error role with retry capability',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSessionCard(BuildContext context, AuthUser user) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.accent,
              foregroundColor: AppPalette.white,
              radius: AppSpacing.xl,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AdaptiveButton(
              text: 'Sign Out',
              type: AdaptiveButtonType.secondary,
              onPressed: () {
                context.read<AuthCubit?>()?.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
