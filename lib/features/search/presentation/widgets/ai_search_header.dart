import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:go_router/go_router.dart';

/// Pinned collapsible header for the AI Gallery Search screen.
/// Implements a native iOS-style collapsible navigation bar with:
/// - Pinned circular back button (50px) at top-left inside safe area.
/// - Unscrolled state: Transparent background, zero border, compact title omitted,
///   large "AI Search" title and subtitle visible below.
/// - Scrolled state: Translucent frosted blur (`BackdropFilter`), white 85% opacity,
///   subtle bottom border `#E5E7EB`, and compact centered "AI Search" title.
class AiSearchHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const AiSearchHeader({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.horizontalGutter(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: AiSearchHeaderDelegate(
        topPadding: topPadding,
        horizontalGutter: gutter,
        onBackTap: onBackTap,
      ),
    );
  }
}

/// Custom [SliverPersistentHeaderDelegate] driving the smooth scroll-driven transition
/// between the expanded large header and the compact pinned navigation bar with blur.
class AiSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final double horizontalGutter;
  final VoidCallback? onBackTap;

  static const double _toolbarHeight = 56.0;
  static const double _expandedContentHeight = 90.0;

  const AiSearchHeaderDelegate({
    required this.topPadding,
    required this.horizontalGutter,
    this.onBackTap,
  });

  @override
  double get minExtent => topPadding + _toolbarHeight;

  @override
  double get maxExtent => minExtent + _expandedContentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double maxShrink = maxExtent - minExtent;
    final double progress = maxShrink > 0
        ? (shrinkOffset / maxShrink).clamp(0.0, 1.0)
        : 0.0;

    // Compact title fades in during the latter half of the collapse
    final double compactOpacity = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);

    // Large title fades out rapidly as it scrolls upward
    final double largeOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);

    // Background blur and border opacity
    final double bgOpacity = progress;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Frosted glass background & bottom divider for pinned toolbar
          if (bgOpacity > 0.01)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 16.0 * bgOpacity,
                    sigmaY: 16.0 * bgOpacity,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85 * bgOpacity),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFE5E7EB)
                              .withValues(alpha: bgOpacity),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 2. Large Title & Subtitle (scrolls up and fades out)
          if (largeOpacity > 0.01)
            Positioned(
              top: topPadding + _toolbarHeight + 4.0 - (shrinkOffset * 0.8),
              left: horizontalGutter,
              right: horizontalGutter,
              child: Opacity(
                opacity: largeOpacity,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI Search',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Find photos, people, places and more',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Compact Centered Title (only built when scrolled past threshold)
          if (compactOpacity > 0.01)
            Positioned(
              top: topPadding,
              left: horizontalGutter + 56.0,
              right: horizontalGutter + 56.0,
              height: _toolbarHeight,
              child: Center(
                child: Opacity(
                  opacity: compactOpacity,
                  child: const Text(
                    'AI Search',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
            ),

          // 4. Circular Back Button (pinned at top-left inside safe area)
          Positioned(
            top: topPadding + (_toolbarHeight - 50.0) / 2,
            left: horizontalGutter,
            width: 50.0,
            height: 50.0,
            child: Semantics(
              button: true,
              label: 'Back',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap:
                      onBackTap ??
                      () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppSvgIcon(
                        AppIcons.chevronRight,
                        color: Color(0xFF111827),
                        size: 22,
                        quarterTurns: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant AiSearchHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.horizontalGutter != horizontalGutter ||
        oldDelegate.onBackTap != onBackTap;
  }
}
