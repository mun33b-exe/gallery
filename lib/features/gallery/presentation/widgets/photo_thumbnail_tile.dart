import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/adaptive/adaptive_progress_indicator.dart';
import '../../domain/photo_model.dart';
import '../../domain/photo_repository.dart';

/// Memory-efficient thumbnail cell for the gallery grid.
/// Enforces small thumbnail loading to protect against Out-Of-Memory (OOM) crashes.
class PhotoThumbnailTile extends StatefulWidget {
  final PhotoModel photo;
  final PhotoRepository photoRepository;
  final VoidCallback? onTap;

  const PhotoThumbnailTile({
    super.key,
    required this.photo,
    required this.photoRepository,
    this.onTap,
  });

  @override
  State<PhotoThumbnailTile> createState() => _PhotoThumbnailTileState();
}

class _PhotoThumbnailTileState extends State<PhotoThumbnailTile> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant PhotoThumbnailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.id != widget.photo.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final bytes = await widget.photoRepository.getThumbnail(
        widget.photo.id,
        width: 250,
        height: 250,
      );

      if (mounted) {
        setState(() {
          _thumbnailBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusSm,
      child: Material(
        color: colors.surfaceSecondary,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isLoading)
                const Center(
                  child: AdaptiveProgressIndicator(size: AppSpacing.lg),
                )
              else if (_hasError || _thumbnailBytes == null)
                Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colors.textMuted,
                    size: AppSpacing.xl,
                  ),
                )
              else
                Image.memory(
                  _thumbnailBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),

              // Favorite indicator badge
              if (widget.photo.isFavorite)
                Positioned(
                  bottom: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: AppPalette.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppPalette.rose500,
                      size: AppSpacing.md,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
