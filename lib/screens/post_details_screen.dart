import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/comment_tile.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isPerformingAction = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(String postId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await ref.read(supabaseServiceProvider).addComment(postId, text);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e'), backgroundColor: const Color(0xFFBA1A1A)),
      );
    } finally {
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  Future<void> _deleteComment(String postId, String commentId) async {
    try {
      await ref.read(supabaseServiceProvider).deleteComment(commentId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }

  Future<void> _handleClaimStatus(String claimId, String status, String postId) async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      final service = ref.read(supabaseServiceProvider);
      
      await service.updateClaimStatus(claimId, status);
      
      if (status == 'accepted') {
        await service.updatePostStatus(postId, 'resolved');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claim successfully $status!'),
          backgroundColor: status == 'accepted' ? const Color(0xFF1A73E8) : const Color(0xFFBA1A1A),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e'), backgroundColor: const Color(0xFFBA1A1A)),
      );
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _claimItem(String postId) async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      await ref.read(supabaseServiceProvider).createClaim(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recovery claim submitted successfully!'),
          backgroundColor: Color(0xFF1A73E8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim: $e'), backgroundColor: const Color(0xFFBA1A1A)),
      );
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _markResolved(String postId) async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      await ref.read(supabaseServiceProvider).updatePostStatus(postId, 'resolved');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item marked as resolved!'),
          backgroundColor: Color(0xFF1A73E8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A73E8);
    const onSurface = Color(0xFF191C1D);
    const outlineColor = Color(0xFF727785);
    const outlineVariant = Color(0xFFE1E3E4);
    const surfaceContainer = Color(0xFFF3F4F5);

    final postId = ModalRoute.of(context)!.settings.arguments as String;
    final postAsyncValue = ref.watch(postDetailsProvider(postId));
    final commentsAsyncValue = ref.watch(commentsProvider(postId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.5)),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: postAsyncValue.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.', style: TextStyle(fontFamily: 'Inter')));
          }

          final isOwner = currentUser?.id == post.userId;
          final isLost = post.isLost;
          final isResolved = post.isResolved;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card with image
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                        Container(
                          height: 320,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(post.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          color: surfaceContainer,
                          alignment: Alignment.center,
                          child: Icon(
                            isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
                            size: 48,
                            color: outlineColor.withOpacity(0.5),
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row: Category & Status tags
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isLost ? const Color(0xFFFFDAD6) : const Color(0xFF89FA9B),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        post.type.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                          color: isLost ? const Color(0xFF93000A) : const Color(0xFF002108),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: surfaceContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        post.category,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF414754),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Status
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isResolved ? const Color(0xFFD3F9D8) : const Color(0xFFFFEC99),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    post.status.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: isResolved ? const Color(0xFF002108) : const Color(0xFF4D3A00),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Title
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Description
                            Text(
                              post.description,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: onSurface.withOpacity(0.8),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(height: 1, thickness: 1, color: outlineVariant),
                            ),

                            // Location & Date Rows
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF93000A)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('LOCATION', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: outlineColor)),
                                      Text(post.location, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: onSurface)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFD8E2FF), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF001A41)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('REPORTED ON', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: outlineColor)),
                                      Text('${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year} at ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: onSurface)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Interactive Actions Section
                      if (!isResolved) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28), // M3 Card Radius
                              border: Border.all(color: outlineVariant, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isOwner 
                                      ? 'Owner Controls' 
                                      : (isLost ? 'Help Find This Item' : 'Claim Recovered Item'),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isOwner
                                      ? 'Mark this item as resolved if you recovered it or returned it to its owner.'
                                      : (isLost 
                                          ? 'Write comment below if you have any leads on where this item is.'
                                          : 'If this is your item, submit a claim request. The finder will review it.'),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: outlineColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                if (isOwner)
                                  ElevatedButton(
                                    onPressed: _isPerformingAction ? null : () => _markResolved(post.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD3F9D8),
                                      foregroundColor: const Color(0xFF002108),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: _isPerformingAction
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF002108)),
                                          )
                                        : const Text('Mark as Resolved', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15)),
                                  )
                                else if (!isLost)
                                  ElevatedButton(
                                    onPressed: _isPerformingAction ? null : () => _claimItem(post.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: _isPerformingAction
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                          )
                                        : const Text('Submit Recovery Claim', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: surfaceContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Leave a comment below if you have any details!',
                                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF414754)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // CLAIMS MANAGEMENT DASHBOARD (OWNER ONLY)
                      if (isOwner) ...[
                        ref.watch(postClaimsProvider(post.id)).when(
                          data: (claims) {
                            if (claims.isEmpty) return const SizedBox.shrink();
                            
                            return Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: outlineVariant, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.assignment_turned_in_rounded, color: primaryColor),
                                      SizedBox(width: 8),
                                      Text(
                                        'Incoming Claims',
                                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 18, color: onSurface),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: claims.length,
                                    itemBuilder: (context, index) {
                                      final claim = claims[index];
                                      final claimId = claim['id'] as String;
                                      final currentStatus = claim['status'] as String;
                                      final profile = claim['profiles'] as Map<String, dynamic>?;
                                      final claimantName = profile?['username'] ?? 'Anonymous User';

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: surfaceContainer,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    claimantName,
                                                    style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Status: ${currentStatus.toUpperCase()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: currentStatus == 'accepted'
                                                          ? const Color(0xFF002108)
                                                          : currentStatus == 'rejected'
                                                              ? const Color(0xFF93000A)
                                                              : outlineColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (currentStatus == 'pending' && !_isPerformingAction) ...[
                                              IconButton(
                                                icon: const Icon(Icons.cancel_outlined, color: Color(0xFFBA1A1A)),
                                                onPressed: () => _handleClaimStatus(claimId, 'rejected', post.id),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => _handleClaimStatus(claimId, 'accepted', post.id),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1A73E8),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  elevation: 0,
                                                ),
                                                child: const Text('Accept', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                              ),
                                            ] else if (currentStatus != 'pending') ...[
                                              Icon(
                                                currentStatus == 'accepted' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                                color: currentStatus == 'accepted' ? const Color(0xFF1A73E8) : const Color(0xFFBA1A1A),
                                              )
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: primaryColor))),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ],

                      // Comments Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          'Comments Thread',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),

                      // Comments list view
                      commentsAsyncValue.when(
                        data: (comments) {
                          if (comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  'No comments yet. Start the conversation!',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: outlineColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return CommentTile(
                                comment: comment,
                                canDelete: currentUser?.id == comment.userId || isOwner,
                                onDelete: () => _deleteComment(post.id, comment.id),
                              );
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator(color: primaryColor)),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('Error: $err', style: const TextStyle(fontWeight: FontWeight.w600))),
                        ),
                      ),
                      const SizedBox(height: 120), // Padding for the bottom comment box
                    ],
                  ),
                ),
              ),
              
              // Bottom Comment Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: outlineVariant, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ]
                ),
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(fontFamily: 'Inter', color: outlineColor, fontWeight: FontWeight.w400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: surfaceContainer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: primaryColor, width: 1),
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: onSurface, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isSubmittingComment ? null : () => _addComment(post.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _isSubmittingComment
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFBA1A1A)),
          ),
        ),
      ),
    );
  }
}