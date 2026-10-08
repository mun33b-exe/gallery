import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:go_router/go_router.dart';

/// Asymmetric recent media grid matching the design specification.
/// Strictly limited to the first two preview rows (maximum 5 photos total):
/// - Row 1: 2 photos (1 large landscape + 1 square/portrait)
/// - Row 2: Up to 3 photos with contextual badges (document preview, chat preview, group preview)
/// Tapping "See all >" navigates to the dedicated All Photos gallery screen (/all-photos).
class RecentAsymmetricGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    final gutter = Responsive.horizontalGutter(context);
    final previewPhotos = photos.take(5).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
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
                  if (onSeeAllTap != null) {
                    onSeeAllTap!();
                  } else {
                    context.push('/all-photos');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(width: 2),
                      AppSvgIcon(
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

          // Strictly 2 preview rows (max 5 photos)
          _buildAsymmetricFeatured(previewPhotos),
        ],
      ),
    );
  }

  Widget _buildAsymmetricFeatured(List<PhotoModel> previewPhotos) {
    return Column(
      children: [
        // Row 1: 1 large landscape (flex: 6) + 1 square (flex: 4)
        SizedBox(
          height: 190,
          child: Row(
            children: [
              // Large landscape photo
              Expanded(
                flex: 6,
                child: _buildBadgedTile(
                  photo: previewPhotos[0],
                  index: 0,
                  icon: AppIcons.image,
                ),
              ),
              if (previewPhotos.length > 1) ...[
                const SizedBox(width: AppSpacing.sm),
                // Smaller square/portrait photo
                Expanded(
                  flex: 4,
                  child: _buildBadgedTile(
                    photo: previewPhotos[1],
                    index: 1,
                    icon: AppIcons.coffee,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Row 2: Up to 3 preview items
        if (previewPhotos.length > 2) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 135,
            child: Row(
              children: [
                Expanded(
                  child: _buildBadgedTile(
                    photo: previewPhotos[2],
                    index: 2,
                    icon: AppIcons.fileText,
                  ),
                ),
                if (previewPhotos.length > 3) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildBadgedTile(
                      photo: previewPhotos[3],
                      index: 3,
                      icon: AppIcons.messageCircle,
                    ),
                  ),
                ],
                if (previewPhotos.length > 4) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildBadgedTile(
                      photo: previewPhotos[4],
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
            photoRepository: photoRepository,
            onTap: () => onPhotoTap(photo, index),
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
}
