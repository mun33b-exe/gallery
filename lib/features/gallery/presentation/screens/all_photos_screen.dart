import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:gallery/features/gallery/domain/category_model.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_state.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/category_filter_bar.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:go_router/go_router.dart';

/// Dedicated Full Media Gallery screen displaying all photos.
/// Features:
/// - iOS-style header with circular back button, "All Photos" title, and photo count badge.
/// - Integrated [CategoryFilterBar] for category/album filtering.
/// - Responsive 3-column media grid with [PhotoThumbnailTile] and hero transitions.
/// - Tap to open [PhotoViewerScreen].
class AllPhotosScreen extends StatelessWidget {
  const AllPhotosScreen({super.key});

  void _openPhotoViewer(
    BuildContext context,
    List<PhotoModel> photos,
    int index,
  ) {
    try {
      context.push(
        '/photo-viewer',
        extra: PhotoViewerArgs(photos: photos, initialIndex: index),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.horizontalGutter(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoading || state is GalleryPermissionChecking) {
              return const Center(
                child: AdaptiveProgressIndicator(size: AppSpacing.xxxl),
              );
            }

            if (state is GalleryError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(gutter),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppSvgIcon(
                        AppIcons.circleAlert,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final photos = state is GalleryLoaded
                ? state.photos
                : <PhotoModel>[];
            final categories = state is GalleryLoaded
                ? state.categories
                : <CategoryModel>[];
            final selectedCategory = state is GalleryLoaded
                ? state.selectedCategory
                : null;
            final photoRepo = context.read<GalleryCubit>().photoRepository;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Top Header: Circular Back button + Title & Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppSpacing.sm,
                      gutter,
                      AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular back button
                        Semantics(
                          button: true,
                          label: 'Back',
                          child: InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: AppSvgIcon(
                                  AppIcons.chevronLeft,
                                  color: Color(0xFF111827),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Title + Count
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'All Photos',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${photos.length} Photos',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Filter Bar
                if (categories.isNotEmpty && selectedCategory != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: CategoryFilterBar(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (cat) {
                          context.read<GalleryCubit>().selectCategory(cat);
                        },
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),

                // Empty Category State
                if (photos.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(gutter),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            AppSvgIcon(
                              AppIcons.image,
                              size: 48,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'No Photos Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'There are no photos in this category.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Responsive 3-Column Media Grid
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                            childAspectRatio: 1.0,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final photo = photos[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: PhotoThumbnailTile(
                            photo: photo,
                            photoRepository: photoRepo,
                            onTap: () =>
                                _openPhotoViewer(context, photos, index),
                          ),
                        );
                      }, childCount: photos.length),
                    ),
                  ),

                // Bottom safe margin clearance
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
