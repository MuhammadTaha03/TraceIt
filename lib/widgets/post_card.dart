import 'dart:ui';
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
    
    // Theme Colors matching DESIGN.md specs
    final primaryColor = isLost ? const Color(0xFFBA1A1A) : const Color(0xFF006D2C);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE1E3E4), // outline-variant color
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27), // Offset by 1px to prevent border bleed
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: primaryColor.withOpacity(0.08),
            highlightColor: primaryColor.withOpacity(0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image / Placeholder Stack
                Stack(
                  children: [
                    if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                      Image.network(
                        post.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isLost),
                      )
                    else
                      _buildPlaceholder(isLost),
                    
                    // Category Tag (Top Left)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildGlassmorphicCategoryChip(post.category),
                    ),

                    // Status & Type Tags (Top Right)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lost / Found Tag
                          _buildGlassmorphicChip(
                            text: post.type.toUpperCase(),
                            isLost: isLost,
                          ),
                          const SizedBox(width: 8),
                          // Status Tag
                          _buildGlassmorphicChip(
                            text: post.status.toUpperCase(),
                            isResolvedChip: true,
                            isResolved: post.isResolved,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Text Content Area with 24px Padding
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20, // title-lg
                          fontWeight: FontWeight.w600, // SemiBold
                          height: 1.4, // 28px line-height
                          color: Color(0xFF191C1D), // on-surface
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        post.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14, // body-md
                          fontWeight: FontWeight.w400,
                          height: 1.43, // 20px line-height
                          color: Color(0xFF414754), // on-surface-variant
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Footer: Location & Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location Icon and Text
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF727785), // outline
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    post.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12, // label-lg
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF414754), // on-surface-variant
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Relative Date Text
                          Text(
                            _formatDate(post.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11, // label-md
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF727785), // outline
                            ),
                          ),
                        ],
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

  // Beautiful placeholder with soft linear gradient and icon
  Widget _buildPlaceholder(bool isLost) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA), // surface
            Color(0xFFEDEEEF), // surface-container
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
            color: const Color(0xFF727785), // outline
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            isLost ? 'Looking for this item' : 'Found and kept safe',
            style: const TextStyle(
              color: Color(0xFF414754), // on-surface-variant
              fontWeight: FontWeight.w500,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // Reusable glassmorphic chip creator
  Widget _buildGlassmorphicChip({
    required String text,
    bool isLost = false,
    bool isResolvedChip = false,
    bool isResolved = false,
  }) {
    final Color baseColor;
    final Color textColor;
    
    if (isResolvedChip) {
      baseColor = isResolved ? const Color(0xFF89FA9B) : const Color(0xFFFFEC99);
      textColor = isResolved ? const Color(0xFF002108) : const Color(0xFF7A5F00);
    } else {
      baseColor = isLost ? const Color(0xFFFFDAD6) : const Color(0xFF89FA9B);
      textColor = isLost ? const Color(0xFF93000A) : const Color(0xFF002108);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: 'Inter',
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // Custom glassmorphic chip for Category tag
  Widget _buildGlassmorphicCategoryChip(String category) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5).withOpacity(0.85), // surface-container-low
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: Color(0xFF414754), // on-surface-variant
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: 'Inter',
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
