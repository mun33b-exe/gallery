import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../cubit/auth_cubit.dart';

/// Initial screen that validates the user session and dispatches to GoRouter.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.xxxl * 1.5,
                height: AppSpacing.xxxl * 1.5,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: AppSpacing.borderRadiusLg,
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  size: AppSpacing.xxxl,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'AI Gallery',
                style: textTheme.headlineLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Intelligent, Private Photo Experience',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const AdaptiveProgressIndicator(size: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
