import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../domain/photo_model.dart';
import '../../domain/photo_repository.dart';

/// Memory suggestion item representation.
class SuggestionMemory {
  final String title;
  final String subtitle;
  final PhotoModel? photo;
  final Color fallbackColor;

  const SuggestionMemory({
    required this.title,
    required this.subtitle,
    this.photo,
    required this.fallbackColor,
  });
}

/// Horizontal carousel displaying curated visual memories and suggestion cards
/// backed by real photos from [GalleryCubit].
class SuggestionsCarousel extends StatelessWidget {
  final List<PhotoModel> photos;
  final PhotoRepository photoRepository;
  final void Function(PhotoModel photo, int index)? onMemoryTap;
  final VoidCallback? onSeeAllTap;

  const SuggestionsCarousel({
    super.key,
    required this.photos,
    required this.photoRepository,
    this.onMemoryTap,
    this.onSeeAllTap,
  });

  List<SuggestionMemory> _buildMemories() {
    final count = photos.length;
    return [
      SuggestionMemory(
        title: 'Best of September',
        subtitle: '${count > 0 ? count : 42} photos',
        photo: photos.isNotEmpty ? photos[0] : null,
        fallbackColor: const Color(0xFF3B82F6),
      ),
      SuggestionMemory(
        title: 'Selfies',
        subtitle: '${count > 1 ? count * 3 : 128} photos',
        photo: photos.length > 1 ? photos[1] : null,
        fallbackColor: const Color(0xFF10B981),
      ),
      SuggestionMemory(
        title: 'Two years ago',
        subtitle: '${count > 2 ? count * 2 : 96} photos',
        photo: photos.length > 2 ? photos[2] : null,
        fallbackColor: const Color(0xFFF59E0B),
      ),
      SuggestionMemory(
        title: 'Videos',
        subtitle: '${count > 3 ? (count / 2).ceil() : 32} videos',
        photo: photos.length > 3 ? photos[3] : null,
        fallbackColor: const Color(0xFF8B5CF6),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final memories = _buildMemories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Suggestions',
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
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: const [
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
        ),

        const SizedBox(height: AppSpacing.md),

        // Horizontal memory card list
        SizedBox(
          height: 265,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: memories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final memory = memories[index];
              return _MemoryCard(
                memory: memory,
                photoRepository: photoRepository,
                onTap: () {
                  if (memory.photo != null) {
                    onMemoryTap?.call(memory.photo!, index);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final SuggestionMemory memory;
  final PhotoRepository photoRepository;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.memory,
    required this.photoRepository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${memory.title}, ${memory.subtitle}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 215,
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Photo or Gradient Fallback
                if (memory.photo != null)
                  _buildPhotoBackground(memory.photo!)
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          memory.fallbackColor,
                          memory.fallbackColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),

                // Scrim Overlay for contrast
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [Colors.transparent, Color(0xD9000000)],
                    ),
                  ),
                ),

                // Card Labels and Action Arrow
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              memory.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              memory.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xD9FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AppSvgIcon(
                            AppIcons.arrowRight,
                            color: Color(0xFF111827),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBackground(PhotoModel photo) {
    return FutureBuilder<Uint8List?>(
      future: photoRepository.getThumbnail(photo.id, width: 300, height: 300),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            cacheWidth: 300,
            cacheHeight: 300,
          );
        }
        return Container(
          color: const Color(0xFF1F2937),
          child: const Center(
            child: AppSvgIcon(AppIcons.image, color: Colors.white30, size: 32),
          ),
        );
      },
    );
  }
}
