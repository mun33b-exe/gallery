import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/adaptive/adaptive_button.dart';
import '../../../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../../domain/category_model.dart';
import '../cubit/gallery_cubit.dart';
import '../cubit/gallery_state.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/photo_thumbnail_tile.dart';
import 'photo_viewer_screen.dart';

/// Responsive, platform-adaptive Gallery Screen.
/// Strictly enforces thumbnail loading, responsive column adaptation,
/// permission handling, and lazy pagination.
class GalleryScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const GalleryScreen({super.key, this.onOpenSettings});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryCubit>().loadInitialPhotos();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger next page when within 250px of bottom
    if (maxScroll - currentScroll <= 250.0) {
      context.read<GalleryCubit>().loadMorePhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: isIOS
          ? _buildCupertinoHeader(context)
          : _buildMaterialHeader(context),
      body: SafeArea(
        child: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            if (state is GalleryPermissionChecking || state is GalleryLoading) {
              return const Center(
                child: AdaptiveProgressIndicator(size: AppSpacing.xxxl),
              );
            }

            if (state is GalleryPermissionDenied) {
              return _buildPermissionDeniedView(context);
            }

            if (state is GalleryEmpty) {
              return _buildEmptyView(context, state);
            }

            if (state is GalleryError) {
              return _buildErrorView(context, state.message);
            }

            if (state is GalleryLoaded) {
              return _buildLoadedGrid(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMaterialHeader(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final columns = Responsive.galleryColumns(context);
    final deviceType = Responsive.deviceType(context);

    return AppBar(
      title: Text(
        'Photos',
        style: textTheme.headlineMedium?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
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
                '${deviceType.name.toUpperCase()} (${columns}col)',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildCupertinoHeader(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final columns = Responsive.galleryColumns(context);

    return CupertinoNavigationBar(
      backgroundColor: colors.surfacePrimary,
      border: Border(bottom: BorderSide(color: colors.border)),
      middle: Text(
        'Photos',
        style: textTheme.headlineMedium?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppSpacing.borderRadiusFull,
              border: Border.all(color: colors.border),
            ),
            child: Text(
              '${columns}col',
              style: textTheme.labelSmall?.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            onPressed: () => context.push('/settings'),
            child: Icon(
              CupertinoIcons.settings,
              color: colors.textSecondary,
              size: AppSpacing.xl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: AppSpacing.xxxl * 1.5,
              color: colors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Photo Access Required',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'To view and organize your photos, please enable photo library permissions in your device settings.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AdaptiveButton(
              text: 'Open Device Settings',
              onPressed: () {
                context.read<GalleryCubit>().openAppSettings();
                widget.onOpenSettings?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, GalleryEmpty state) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final category = state.selectedCategory;
    final isFavorites = category?.type == CategoryType.favorites;
    final isScreenshots = category?.type == CategoryType.screenshots;

    IconData icon;
    String title;
    String subtitle;

    if (state.isLimitedPermission) {
      icon = Icons.photo_library_outlined;
      title = 'No Photos Selected';
      subtitle = 'You granted limited photo access, but have not selected any photos yet.';
    } else if (isFavorites) {
      icon = Icons.favorite_border;
      title = 'No Favorites Yet';
      subtitle = 'Tap the heart icon on any photo in the viewer to add it to your favorites.';
    } else if (isScreenshots) {
      icon = Icons.screenshot_outlined;
      title = 'No Screenshots Found';
      subtitle = 'No screenshots were found on your device.';
    } else {
      icon = Icons.photo_library_outlined;
      title = 'No Photos Found';
      subtitle = category != null
          ? 'No photos found in ${category.title}.'
          : 'Your device photo library does not contain any photos.';
    }

    return Column(
      children: [
        if (state.categories.isNotEmpty && category != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: CategoryFilterBar(
              categories: state.categories,
              selectedCategory: category,
              onCategorySelected: (cat) =>
                  context.read<GalleryCubit>().selectCategory(cat),
            ),
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: AppSpacing.xxxl * 1.5,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (category != null && category.type != CategoryType.all)
                    AdaptiveButton(
                      text: 'View All Photos',
                      type: AdaptiveButtonType.primary,
                      onPressed: () {
                        final allCategory = state.categories.firstWhere(
                          (c) => c.type == CategoryType.all,
                          orElse: () => category,
                        );
                        context.read<GalleryCubit>().selectCategory(
                          allCategory,
                        );
                      },
                    )
                  else
                    AdaptiveButton(
                      text: state.isLimitedPermission
                          ? 'Manage Selection'
                          : 'Refresh Library',
                      type: AdaptiveButtonType.secondary,
                      onPressed: () {
                        if (state.isLimitedPermission) {
                          context.read<GalleryCubit>().openAppSettings();
                        } else {
                          context.read<GalleryCubit>().refreshPhotos();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSpacing.xxxl * 1.5,
              color: colors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unable to Load Photos',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AdaptiveButton(
              text: 'Try Again',
              onPressed: () => context.read<GalleryCubit>().refreshPhotos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedGrid(BuildContext context, GalleryLoaded state) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final columns = Responsive.galleryColumns(context);
    final gutter = Responsive.horizontalGutter(context);
    final photoRepo = context.read<GalleryCubit>().photoRepository;

    return Column(
      children: [
        if (state.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: CategoryFilterBar(
              categories: state.categories,
              selectedCategory: state.selectedCategory,
              onCategorySelected: (cat) =>
                  context.read<GalleryCubit>().selectCategory(cat),
            ),
          ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Limited permission notice banner if applicable
              if (state.isLimitedPermission)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      gutter,
                      AppSpacing.sm,
                      gutter,
                      AppSpacing.sm,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: AppSpacing.borderRadiusMd,
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.accent,
                          size: AppSpacing.xl,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Limited photo library access active.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        AdaptiveButton(
                          text: 'Manage',
                          type: AdaptiveButtonType.text,
                          onPressed: () =>
                              context.read<GalleryCubit>().openAppSettings(),
                        ),
                      ],
                    ),
                  ),
                ),

              // Responsive grid of thumbnails
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: gutter,
                  vertical: AppSpacing.md,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: AppSpacing.xs,
                    crossAxisSpacing: AppSpacing.xs,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final photo = state.photos[index];
                    return PhotoThumbnailTile(
                      photo: photo,
                      photoRepository: photoRepo,
                      onTap: () {
                        context.push(
                          '/photo-viewer',
                          extra: PhotoViewerArgs(
                            photos: state.photos,
                            initialIndex: index,
                          ),
                        );
                      },
                    );
                  }, childCount: state.photos.length),
                ),
              ),

              // Lazy pagination spinner
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: AdaptiveProgressIndicator(size: AppSpacing.xl),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
