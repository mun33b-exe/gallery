import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_colors.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gallery/features/auth/presentation/cubit/auth_state.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_entitlement.dart';
import '../widgets/membership_card.dart';
import '../widgets/pro_features_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/sign_out_button.dart';

/// Redesigned Profile and Membership screen matching `profile_design.md`
/// and `Modern Profile and Membership Screen.png`.
/// Features clean white canvas, circular back button, dynamic user identity card,
/// plan & membership status with Free Plan badge, upcoming pro features section
/// with interactive preview sheets, and a guarded soft-orange Sign Out button.
class ProfileScreen extends StatelessWidget {
  final UserEntitlement entitlement;

  const ProfileScreen({super.key, this.entitlement = UserEntitlement.freeTier});

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.horizontalGutter(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

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
                  // 1. Header (Back button, Profile title, Subtitle; NO settings button)
                  ProfileHeader(
                    onBackTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // 2. Account Identity Card (User Avatar Initials, Display Name, Email)
                  ProfileIdentityCard(user: user),

                  const SizedBox(height: 20),

                  // 3. Plan & Membership Card (Crown, Title, Free Plan Badge, Description)
                  MembershipCard(entitlement: entitlement),

                  const SizedBox(height: 28),

                  // 4. Upcoming Pro Features Section (Sparkles, 3 Cards with Preview Sheets)
                  const ProFeaturesSection(),

                  const SizedBox(height: 36),

                  // 5. Sign Out Button with Platform-Adaptive Confirmation Dialog
                  SignOutButton(
                    onConfirmSignOut: () async {
                      await context.read<AuthCubit>().logout();
                    },
                  ),

                  const SizedBox(height: 36),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
