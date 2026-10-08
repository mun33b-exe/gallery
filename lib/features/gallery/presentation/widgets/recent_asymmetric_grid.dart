import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../domain/photo_model.dart';
import '../../domain/photo_repository.dart';
import 'photo_thumbnail_tile.dart';

/// Asymmetric recent media grid matching the design specification.
/// Features a hero landscape photo + portrait photo on the first row,
/// and a 3-item preview row on the second row with contextual badges,
/// followed by subsequent photos in a responsive grid.
class RecentAsymmetricGrid extends StatefulWidget {
  final List<PhotoModel> photos;
  final PhotoRepository photoRepository;
  final void Function(PhotoModel photo, int index) onPhotoTap;
  final VoidCallback? onSeeAllTap;

  const RecentAsymmetricGrid({
    super.key,
    required this.photos,
    required this.photoRepository,
    required this.onPhotoTap,
    this.onSeeAllTap,
  });

  @override
  State<RecentAsymmetricGrid> createState() => _RecentAsymmetricGridState();
}

class _RecentAsymmetricGridState extends State<RecentAsymmetricGrid> {
  bool _showAllGrid = false;

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: "Recent" and "See all >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: () {
                  setState(() {
                    _showAllGrid = !_showAllGrid;
                  });
                  widget.onSeeAllTap?.call();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _showAllGrid ? 'Compact' : 'See all',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const AppSvgIcon(
                        AppIcons.chevronRight,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // If not in show-all mode, show the featured asymmetric layout
          if (!_showAllGrid) ...[
            _buildAsymmetricFeatured(),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Render the remaining / full photos as grid tiles
          _buildRemainingGrid(),
        ],
      ),
    );
  }

  Widget _buildAsymmetricFeatured() {
    final photos = widget.photos;

    return Column(
      children: [
        // Top Row: 1 large landscape (flex: 6) + 1 square (flex: 4)
        SizedBox(
          height: 190,
          child: Row(
            children: [
              // Large landscape photo
              Expanded(
                flex: 6,
                child: _buildBadgedTile(
                  photo: photos[0],
                  index: 0,
                  icon: AppIcons.image,
                ),
              ),
              if (photos.length > 1) ...[
                const SizedBox(width: AppSpacing.sm),
                // Smaller photo
                Expanded(
                  flex: 4,
                  child: _buildBadgedTile(
                    photo: photos[1],
                    index: 1,
                    icon: AppIcons.coffee,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom Row: Up to 3 preview items
        if (photos.length > 2) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 135,
            child: Row(
              children: [
                Expanded(
                  child: _buildBadgedTile(
                    photo: photos[2],
                    index: 2,
                    icon: AppIcons.fileText,
                  ),
                ),
                if (photos.length > 3) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildBadgedTile(
                      photo: photos[3],
                      index: 3,
                      icon: AppIcons.messageCircle,
                    ),
                  ),
                ],
                if (photos.length > 4) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildBadgedTile(
                      photo: photos[4],
                      index: 4,
                      icon: AppIcons.users,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgedTile({
    required PhotoModel photo,
    required int index,
    required String icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PhotoThumbnailTile(
            photo: photo,
            photoRepository: widget.photoRepository,
            onTap: () => widget.onPhotoTap(photo, index),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0x59000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppSvgIcon(icon, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingGrid() {
    final startIndex = _showAllGrid ? 0 : 5;
    if (startIndex >= widget.photos.length) return const SizedBox.shrink();

    final remaining = widget.photos.sublist(startIndex);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: remaining.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, idx) {
        final actualIndex = startIndex + idx;
        final photo = remaining[idx];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoThumbnailTile(
            photo: photo,
            photoRepository: widget.photoRepository,
            onTap: () => widget.onPhotoTap(photo, actualIndex),
          ),
        );
      },
    );
  }
}
