import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../../domain/photo_model.dart';
import '../../domain/photo_repository.dart';
import '../cubit/gallery_cubit.dart';

/// Arguments passed to [PhotoViewerScreen] via GoRouter.
class PhotoViewerArgs {
  final List<PhotoModel> photos;
  final int initialIndex;

  const PhotoViewerArgs({required this.photos, required this.initialIndex});
}

/// Fullscreen interactive photo viewer.
/// Implements horizontal paging, pinch-to-zoom, double-tap zoom reset,
/// immersive overlay toggle, progressive high-res loading, and Rule 5.3 adaptability.
class PhotoViewerScreen extends StatefulWidget {
  final PhotoViewerArgs args;
  final PhotoRepository photoRepository;

  const PhotoViewerScreen({
    super.key,
    required this.args,
    required this.photoRepository,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late List<PhotoModel> _photos;
  late int _currentIndex;
  bool _isOverlayVisible = true;

  @override
  void initState() {
    super.initState();
    _photos = List.of(widget.args.photos);
    _currentIndex = widget.args.initialIndex.clamp(
      0,
      (_photos.length - 1).clamp(0, _photos.length),
    );
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _handleFavoriteToggle() async {
    if (_photos.isEmpty) return;
    final currentPhoto = _photos[_currentIndex];
    final updated = currentPhoto.copyWith(isFavorite: !currentPhoto.isFavorite);

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      unawaited(HapticFeedback.lightImpact());
    }

    setState(() {
      _photos[_currentIndex] = updated;
    });

    if (mounted) {
      try {
        await context.read<GalleryCubit>().toggleFavorite(currentPhoto);
      } catch (_) {}
    }
  }

  Future<void> _handleShare() async {
    if (_photos.isEmpty) return;
    final currentPhoto = _photos[_currentIndex];
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      unawaited(HapticFeedback.selectionClick());
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (modalContext) => CupertinoActionSheet(
          title: Text(currentPhoto.title ?? 'Photo'),
          message: Text('${currentPhoto.width} × ${currentPhoto.height}'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Share Image'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(modalContext).pop(),
              child: const Text('Save to Files'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(modalContext).pop(),
            child: const Text('Cancel'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing ${currentPhoto.title ?? 'Photo'}...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (_photos.isEmpty) return;
    final currentPhoto = _photos[_currentIndex];
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) {
        if (isIOS) {
          return CupertinoAlertDialog(
            title: const Text('Delete Photo'),
            content: const Text(
              'Are you sure you want to remove this photo from your gallery?',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Delete Photo'),
            content: const Text(
              'Are you sure you want to remove this photo from your gallery?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.rose500,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        }
      },
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<GalleryCubit>().removePhoto(currentPhoto.id);
      } catch (_) {}

      setState(() {
        _photos.removeAt(_currentIndex);
        if (_currentIndex >= _photos.length && _photos.isNotEmpty) {
          _currentIndex = _photos.length - 1;
        }
      });

      if (_photos.isEmpty) {
        if (mounted) context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final currentPhoto = _photos.isNotEmpty ? _photos[_currentIndex] : null;

    return Scaffold(
      backgroundColor: AppPalette.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Paging and zoom canvas
          if (_photos.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: _photos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _InteractivePhotoView(
                  key: ValueKey(_photos[index].id),
                  photo: _photos[index],
                  photoRepository: widget.photoRepository,
                  onTap: _toggleOverlay,
                );
              },
            ),

          // Top App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isOverlayVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_isOverlayVisible,
                child: _buildTopBar(context, isIOS, currentPhoto),
              ),
            ),
          ),

          // Bottom Metadata Overlay
          if (currentPhoto != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _isOverlayVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_isOverlayVisible,
                  child: _buildBottomMetadata(context, currentPhoto),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isIOS, PhotoModel? photo) {
    final topPadding = MediaQuery.of(context).padding.top;
    final counterText = _photos.isNotEmpty
        ? '${_currentIndex + 1} of ${_photos.length}'
        : '';

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.xs,
        bottom: AppSpacing.sm,
        left: AppSpacing.sm,
        right: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.black.withValues(alpha: 0.85),
            AppPalette.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          Semantics(
            button: true,
            label: 'Back',
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                    onPressed: () {
                      unawaited(HapticFeedback.selectionClick());
                      context.pop();
                    },
                    child: const Icon(
                      CupertinoIcons.back,
                      color: AppPalette.white,
                      size: 26,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppPalette.white),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                  ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Index indicator
          Text(
            counterText,
            style: const TextStyle(
              color: AppPalette.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Favorite button
          if (photo != null) ...[
            Semantics(
              button: true,
              label: photo.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              child: isIOS
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      onPressed: _handleFavoriteToggle,
                      child: Icon(
                        photo.isFavorite
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: photo.isFavorite
                            ? AppPalette.rose500
                            : AppPalette.white,
                        size: 24,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        photo.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: photo.isFavorite
                            ? AppPalette.rose500
                            : AppPalette.white,
                      ),
                      tooltip: photo.isFavorite ? 'Unfavorite' : 'Favorite',
                      onPressed: _handleFavoriteToggle,
                    ),
            ),

            // Share button
            Semantics(
              button: true,
              label: 'Share photo',
              child: isIOS
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      onPressed: _handleShare,
                      child: const Icon(
                        CupertinoIcons.share,
                        color: AppPalette.white,
                        size: 24,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppPalette.white,
                      ),
                      tooltip: 'Share',
                      onPressed: _handleShare,
                    ),
            ),

            // Delete button
            Semantics(
              button: true,
              label: 'Delete photo',
              child: isIOS
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      onPressed: _handleDelete,
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: AppPalette.rose500,
                        size: 24,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppPalette.rose500,
                      ),
                      tooltip: 'Delete',
                      onPressed: _handleDelete,
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomMetadata(BuildContext context, PhotoModel photo) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dateFormatted = _formatDateTime(photo.createDateTime);

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: bottomPadding + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppPalette.black.withValues(alpha: 0.9),
            AppPalette.black.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            photo.title ?? 'IMG_${photo.id}.jpg',
            style: const TextStyle(
              color: AppPalette.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Text(
                '${photo.width} × ${photo.height}',
                style: const TextStyle(
                  color: AppPalette.slate400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '•',
                style: TextStyle(color: AppPalette.slate500, fontSize: 13),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateFormatted,
                style: const TextStyle(
                  color: AppPalette.slate400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[(dt.month - 1).clamp(0, 11)];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} • $hour:$minute';
  }
}

/// Individual interactive photo canvas with progressive loading and double-tap zoom.
class _InteractivePhotoView extends StatefulWidget {
  final PhotoModel photo;
  final PhotoRepository photoRepository;
  final VoidCallback onTap;

  const _InteractivePhotoView({
    super.key,
    required this.photo,
    required this.photoRepository,
    required this.onTap,
  });

  @override
  State<_InteractivePhotoView> createState() => _InteractivePhotoViewState();
}

class _InteractivePhotoViewState extends State<_InteractivePhotoView> {
  final TransformationController _transformationController =
      TransformationController();
  Uint8List? _thumbnailBytes;
  Uint8List? _fullBytes;
  bool _isLoadingThumbnail = true;
  bool _isLoadingFull = true;

  @override
  void initState() {
    super.initState();
    _loadProgressiveImages();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressiveImages() async {
    // 1. Fetch thumbnail immediately for instant preview
    try {
      final thumb = await widget.photoRepository.getThumbnail(
        widget.photo.id,
        width: 300,
        height: 300,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = thumb;
          _isLoadingThumbnail = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingThumbnail = false;
        });
      }
    }

    // 2. Concurrently fetch high-res bounded preview
    try {
      final full = await widget.photoRepository.getFullPhoto(
        widget.photo.id,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (mounted) {
        setState(() {
          _fullBytes = full;
          _isLoadingFull = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFull = false;
        });
      }
    }
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = details.localPosition;
      final zoomed = Matrix4.identity()
        ..setEntry(0, 0, 2.5)
        ..setEntry(1, 1, 2.5)
        ..setEntry(0, 3, -position.dx * 1.5)
        ..setEntry(1, 3, -position.dy * 1.5);
      _transformationController.value = zoomed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 4.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: () {}, // Required so onDoubleTapDown fires properly
        child: SizedBox.expand(
          child: Center(
            child: Hero(
              tag: 'photo_${widget.photo.id}',
              child: _buildImageContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_fullBytes != null) {
      return Image.memory(
        _fullBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }

    if (_thumbnailBytes != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(
            _thumbnailBytes!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
          if (_isLoadingFull)
            const Positioned(
              bottom: AppSpacing.xl,
              child: AdaptiveProgressIndicator(size: AppSpacing.md),
            ),
        ],
      );
    }

    if (_isLoadingThumbnail) {
      return const Center(
        child: AdaptiveProgressIndicator(size: AppSpacing.xxl),
      );
    }

    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: AppPalette.slate600,
        size: 64,
      ),
    );
  }
}
