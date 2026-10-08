import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/adaptive/adaptive_button.dart';
import '../../../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../domain/category_model.dart';
import '../../domain/photo_model.dart';
import '../cubit/gallery_cubit.dart';
import '../cubit/gallery_state.dart';
import '../widgets/floating_library_nav_bar.dart';
import '../widgets/gallery_assistant_card.dart';
import '../widgets/recent_asymmetric_grid.dart';
import '../widgets/suggestions_carousel.dart';
import 'photo_viewer_screen.dart';

/// Production-ready "Your Library" Home Screen matching design specifications.
/// Implements a white-first aesthetic with iOS-inspired spacious layout,
/// Hero AI Gallery Assistant card, dynamic memory suggestions,
/// asymmetric recent gallery grid, and a floating bottom navigation bar.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenSettings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 0;

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

  void _openPhotoViewer(List<PhotoModel> photos, int index) {
    try {
      context.push(
        '/photo-viewer',
        extra: PhotoViewerArgs(photos: photos, initialIndex: index),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
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
              return _buildLoadedView(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, GalleryLoaded state) {
    final photoRepo = context.read<GalleryCubit>().photoRepository;
    final gutter = Responsive.horizontalGutter(context);

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Greeting, Title, and Profile Avatar Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppSpacing.md,
                      gutter,
                      AppSpacing.md,
                    ),
                    child: _buildHeader(context),
                  ),

                  // AI Gallery Assistant Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    child: GalleryAssistantCard(
                      onFavoritesTap: () {
                        final favCat = state.categories.firstWhere(
                          (c) => c.type == CategoryType.favorites,
                          orElse: () => state.selectedCategory,
                        );
                        context.read<GalleryCubit>().selectCategory(favCat);
                      },
                      onRecentlyAddedTap: () {
                        final allCat = state.categories.firstWhere(
                          (c) => c.type == CategoryType.all,
                          orElse: () => state.selectedCategory,
                        );
                        context.read<GalleryCubit>().selectCategory(allCat);
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Suggestions / Memories Carousel
                  SuggestionsCarousel(
                    photos: state.photos,
                    photoRepository: photoRepo,
                    onMemoryTap: (photo, index) =>
                        _openPhotoViewer(state.photos, index),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Recent Asymmetric Photo Section (strictly 2 preview rows / max 5 photos)
                  RecentAsymmetricGrid(
                    photos: state.photos,
                    photoRepository: photoRepo,
                    onPhotoTap: (photo, index) =>
                        _openPhotoViewer(state.photos, index),
                    onSeeAllTap: () => context.push('/all-photos'),
                  ),

                  // Lazy Pagination Indicator
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(
                        child: AdaptiveProgressIndicator(size: AppSpacing.xl),
                      ),
                    ),

                  // Bottom scroll padding so content scrolls above floating nav
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),

        // Floating Bottom Navigation Bar with Frosted Glass Blur & Vignette
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingLibraryNavBar(
            selectedIndex: _selectedNavIndex,
            onIndexChanged: (idx) {
              setState(() {
                _selectedNavIndex = idx;
              });
              if (idx == 1) {
                context.push('/all-photos');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your Library',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Profile Avatar Button with active online dot
        Semantics(
          button: true,
          label: 'Settings and profile',
          child: Tooltip(
            message: 'Settings',
            child: InkWell(
              onTap: () {
                widget.onOpenSettings?.call();
                try {
                  context.push('/settings');
                } catch (_) {}
              },
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: AppSvgIcon(
                        AppIcons.user,
                        color: Color(0xFF4B5563),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
            AppSvgIcon(
              AppIcons.cameraOff,
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
            AppSvgIcon(
              AppIcons.circleAlert,
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
}
