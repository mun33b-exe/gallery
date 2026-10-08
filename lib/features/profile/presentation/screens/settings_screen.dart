import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/app/theme/theme_cubit.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_state.dart';
import 'package:go_router/go_router.dart';

import '../widgets/about_app_card.dart';
import '../widgets/account_card.dart';
import '../widgets/privacy_guarantee_card.dart';
import '../widgets/settings_header.dart';
import '../widgets/sign_out_button.dart';
import '../widgets/theme_selector_card.dart';

/// Redesigned Settings screen faithfully matching `settings_design.md`
/// and `Modern Orange iOS Settings Screen.png`.
/// Features a minimal iOS-inspired UI, white canvas, circular back button,
/// User Account & Entitlements card, 3-option Theme Selector, Local-Only Privacy Guarantee,
/// Photo Permission status tile, About Application metadata card, and soft warm-orange Sign Out button.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.horizontalGutter(context);

    final themeCubit = context.watch<ThemeCubit?>();
    final activeThemeId = themeCubit?.state.selectedTheme.id ?? 'light';

    final galleryState = context.watch<GalleryCubit?>()?.state;
    final isLimitedPermission =
        galleryState is GalleryLoaded && galleryState.isLimitedPermission;

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Top Header: Back Button, Title "Settings", Profile Avatar
                  SettingsHeader(
                    onBackTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    onProfileTap: () => context.push('/profile'),
                  ),

                  const SizedBox(height: 24),

                  // 2. User Account & Entitlements Card
                  AccountCard(onTap: () => context.push('/profile')),

                  const SizedBox(height: 28),

                  // 3. Appearance & Themes Section (Dark, Light, Midnight Blue)
                  ThemeSelectorCard(
                    activeThemeId: activeThemeId,
                    onSelectTheme: (themeId) {
                      context.read<ThemeCubit>().selectThemeById(themeId);
                    },
                  ),

                  const SizedBox(height: 28),

                  // 4. Privacy & Permissions Section (Guarantee + Photo Permission)
                  PrivacyGuaranteeCard(
                    isLimitedPermission: isLimitedPermission,
                    onManagePermission: () {
                      final cubit = context.read<GalleryCubit?>();
                      cubit?.openAppSettings();
                    },
                  ),

                  const SizedBox(height: 28),

                  // 5. About Application Section
                  const AboutAppCard(),

                  const SizedBox(height: 32),

                  // 6. Sign Out Button with Confirmation Dialog
                  SignOutButton(
                    onConfirmSignOut: () async {
                      await context.read<AuthCubit>().logout();
                    },
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
