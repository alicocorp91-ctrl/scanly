import 'package:flutter/material.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailPath = document.thumbnailPath;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: thumbnailPath != null && File(thumbnailPath).existsSync()
                    ? Image.file(
                        File(thumbnailPath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.description_rounded,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${document.pageCount} sayfa',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('dd MMM').format(document.updatedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}