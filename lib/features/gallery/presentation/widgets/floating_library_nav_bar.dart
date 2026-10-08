import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_svg_icon.dart';

/// Floating pill bottom navigation bar matching the Apple Photos / iOS 18 dock design specification.
/// Features a native frosted glass blur overlay with a subtle dark gradient vignette behind,
/// a dark selected "Library" pill, an inactive "Explore" tab, and a separate floating circular search action.
class FloatingLibraryNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  const FloatingLibraryNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 1. Full-Width Bottom Frosted Glass Blur Layer with Feathered Top Edge (Hit-tests ignored)
        Positioned.fill(
          child: IgnorePointer(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [
                    0.0,
                    0.45,
                  ], // Progressively fades in from 0% to 45% of height
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.35, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Interactive Navigation Pills
        SafeArea(
          top: false,
          bottom: true,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              24, // Breathing room above pills for smooth feathering
              AppSpacing.lg,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Navigation capsule: Library & Explore
                Flexible(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Library tab (Active)
                        Flexible(
                          child: Semantics(
                            button: true,
                            selected: selectedIndex == 0,
                            label: 'Library tab',
                            child: InkWell(
                              onTap: () => onIndexChanged?.call(0),
                              borderRadius: BorderRadius.circular(26),
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedIndex == 0
                                      ? const Color(0xFF111827)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppSvgIcon(
                                      AppIcons.gallery,
                                      color: selectedIndex == 0
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        'Library',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 0
                                              ? Colors.white
                                              : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Explore tab (Inactive)
                        Flexible(
                          child: Semantics(
                            button: true,
                            selected: selectedIndex == 1,
                            label: 'Explore tab',
                            child: InkWell(
                              onTap: () => onIndexChanged?.call(1),
                              borderRadius: BorderRadius.circular(26),
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedIndex == 1
                                      ? const Color(0xFF111827)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppSvgIcon(
                                      AppIcons.compass,
                                      color: selectedIndex == 1
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    Flexible(
                                      child: Text(
                                        'Explore',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 1
                                              ? Colors.white
                                              : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Floating Circular Search Button
                Semantics(
                  button: true,
                  label: 'Search photos',
                  child: InkWell(
                    onTap: () => context.push('/search'),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF3F4F6),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: AppSvgIcon(
                          AppIcons.search,
                          color: Color(0xFF111827),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
