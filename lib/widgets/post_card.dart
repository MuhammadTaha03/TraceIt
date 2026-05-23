import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = post.isLost;
    
    // Aesthetic flat colors
    final typeColor = isLost ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
    final typeTextColor = isLost ? const Color(0xFF7A0E0E) : const Color(0xFF0F5A54);
    final cardBgColor = Colors.white;
    const borderColor = Color(0xFF1E1E1E);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: typeColor.withOpacity(0.1),
          highlightColor: typeColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type Tag & Category & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Lost / Found Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Text(
                            post.type.toUpperCase(),
                            style: TextStyle(
                              color: typeTextColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor.withOpacity(0.15), width: 1.5),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(
                              color: Color(0xFF495057),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: post.isResolved ? const Color(0xFFD3F9D8) : const Color(0xFFFFEC99),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Text(
                        post.status.toUpperCase(),
                        style: TextStyle(
                          color: post.isResolved ? const Color(0xFF2B8A3E) : const Color(0xFFE67E22),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Image placeholder or loaded image
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                  Container(
                    height: 160,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1.5),
                      image: DecorationImage(
                        image: NetworkImage(post.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 80,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor.withOpacity(0.1), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
                          color: borderColor.withOpacity(0.3),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLost ? 'Looking for this item' : 'Found and kept safe',
                          style: TextStyle(
                            color: borderColor.withOpacity(0.4),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: borderColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: borderColor.withOpacity(0.75),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Footer: Location & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Color(0xFFE64980),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.location,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF495057),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: borderColor.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
