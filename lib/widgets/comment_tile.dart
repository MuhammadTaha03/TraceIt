import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final bool canDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1E1E1E);
    final userInitial = comment.username != null && comment.username!.isNotEmpty
        ? comment.username![0].toUpperCase()
        : '?';

    // Generates distinct aesthetic pastel colors for user avatars
    final List<Color> avatarColors = [
      const Color(0xFFFFD93D),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF95A5A6),
      const Color(0xFFA55EEA),
      const Color(0xFF26DE81),
    ];
    final colorIndex = comment.userId.hashCode % avatarColors.length;
    final avatarColor = avatarColors[colorIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.15), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar Container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: avatarColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                userInitial,
                style: const TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Comment Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Username & Date & Delete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.username ?? 'Anonymous User',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: borderColor,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: borderColor.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Content Text
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: borderColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Delete button if authorized
            if (canDelete && onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 18,
                ),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    
    // Enforce absolute difference to handle clock skews or timezone shifts gracefully
    final difference = now.difference(localDateTime).abs();
    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 60) {
      return 'Just now';
    } else if (minutes < 60) {
      return '${minutes}m ago';
    } else if (hours < 24) {
      return '${hours}h ago';
    } else if (days < 30) {
      return '${days}d ago';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (days / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
