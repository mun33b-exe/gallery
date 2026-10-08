import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';

import '../../domain/search_message_model.dart';

/// Renders a single conversational turn in the AI Gallery Search session.
/// Supports natural language explanations, multi-photo preview rows with overflow cards,
/// structured bill due date evidence, and financial breakdown tables.
class ConversationMessageView extends StatelessWidget {
  final SearchMessage message;
  final PhotoRepository photoRepository;
  final void Function(PhotoModel photo, int index) onPhotoTap;
  final VoidCallback? onSeeAllPhotos;

  const ConversationMessageView({
    super.key,
    required this.message,
    required this.photoRepository,
    required this.onPhotoTap,
    this.onSeeAllPhotos,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAiResponseCard(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: const Center(
              child: AppSvgIcon(
                AppIcons.user,
                color: Color(0xFF4B5563),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResponseCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Sparkles Identity Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4E5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppSvgIcon(
                AppIcons.sparkles,
                color: Color(0xFFFF7A00),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Response Body Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source context badge (Rule 29: Privacy / Source Context)
                  if (message.sourceContext != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.sourceContext!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // AI Natural Language Explanation
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                      height: 1.35,
                    ),
                  ),

                  // Visual photo preview row
                  if (message.photos.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildPhotoPreviewRow(context),
                  ],

                  // Document / Receipt structured evidence card
                  if (message.documentEvidence != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildDocumentEvidenceCard(
                      context,
                      message.documentEvidence!,
                    ),
                  ],

                  // Financial analysis breakdown
                  if (message.financialBreakdown != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildFinancialBreakdownCard(
                      context,
                      message.financialBreakdown!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreviewRow(BuildContext context) {
    final previewPhotos = message.photos.take(4).toList();
    final totalCount = message.totalCount ?? message.photos.length;
    final hasOverflow = totalCount > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 82,
          child: Row(
            children: List.generate(previewPhotos.length, (i) {
              final photo = previewPhotos[i];
              final isLast = i == 3 && hasOverflow;
              final overflowCount = totalCount - 3;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < previewPhotos.length - 1 ? AppSpacing.xs : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PhotoThumbnailTile(
                          photo: photo,
                          photoRepository: photoRepository,
                          onTap: () => onPhotoTap(photo, i),
                        ),
                        if (isLast)
                          Semantics(
                            button: true,
                            label: 'See all $totalCount photos',
                            child: InkWell(
                              onTap:
                                  onSeeAllPhotos ?? () => onPhotoTap(photo, i),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.55),
                                child: Center(
                                  child: Text(
                                    '+$overflowCount',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onSeeAllPhotos ?? () => onPhotoTap(message.photos.first, 0),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF7A00),
                    ),
                  ),
                  SizedBox(width: 2),
                  AppSvgIcon(
                    AppIcons.chevronRight,
                    color: Color(0xFFFF7A00),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentEvidenceCard(
    BuildContext context,
    DocumentEvidenceModel evidence,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Document / Calendar Icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF6FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppSvgIcon(
                AppIcons.fileText,
                color: Color(0xFF3B82F6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Extracted Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidence.dueDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  evidence.serviceName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Receipt Preview Thumbnail
          if (evidence.receiptPhoto != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: PhotoThumbnailTile(
                  photo: evidence.receiptPhoto!,
                  photoRepository: photoRepository,
                  onTap: () => onPhotoTap(evidence.receiptPhoto!, 0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdownCard(
    BuildContext context,
    FinancialBreakdownModel breakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                breakdown.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              Text(
                breakdown.totalAmount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md, color: Color(0xFFE5E7EB)),
          ...breakdown.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    item.amount,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
