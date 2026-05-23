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
      // Invalidate comments for this post
      ref.invalidate(commentsProvider(postId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e'), backgroundColor: const Color(0xFFFF6B6B)),
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
      ref.invalidate(commentsProvider(postId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
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
          backgroundColor: Color(0xFF4ECDC4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim: $e'), backgroundColor: const Color(0xFFFF6B6B)),
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
      ref.invalidate(postsProvider);
      ref.invalidate(postDetailsProvider(postId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item marked as resolved!'),
          backgroundColor: Color(0xFF4ECDC4),
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
    const borderColor = Color(0xFF1E1E1E);
    const yellowAccent = Color(0xFFFFD93D);
    const orangeAccent = Color(0xFFFF6B6B);
    const tealAccent = Color(0xFF4ECDC4);

    final postId = ModalRoute.of(context)!.settings.arguments as String;
    final postAsyncValue = ref.watch(postDetailsProvider(postId));
    final commentsAsyncValue = ref.watch(commentsProvider(postId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: borderColor, width: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: borderColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: postAsyncValue.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          final isOwner = currentUser?.id == post.userId;
          final isLost = post.isLost;
          final isResolved = post.isResolved;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card with image
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  border: const Border(
                                    bottom: BorderSide(color: borderColor, width: 2),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(post.imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 140,
                                color: const Color(0xFFF8F9FA),
                                alignment: Alignment.center,
                                child: Icon(
                                  isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
                                  size: 48,
                                  color: borderColor.withOpacity(0.3),
                                ),
                              ),
                            
                            Padding(
                              padding: const EdgeInsets.all(20.0),
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
                                              color: isLost ? orangeAccent : tealAccent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: borderColor, width: 2),
                                            ),
                                            child: Text(
                                              post.type.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                                color: borderColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Status
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isResolved ? const Color(0xFFD3F9D8) : const Color(0xFFFFEC99),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: borderColor, width: 1.5),
                                        ),
                                        child: Text(
                                          post.status.toUpperCase(),
                                          style: TextStyle(
                                            color: isResolved ? const Color(0xFF2B8A3E) : const Color(0xFFE67E22),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Title
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: borderColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  // Description
                                  Text(
                                    post.description,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: borderColor.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                  const Divider(height: 32, thickness: 1),

                                  // Location & Date Rows
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFFE64980)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'LOCATION:  ',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF868E96)),
                                      ),
                                      Text(
                                        post.location,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: borderColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF4C6EF5)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'REPORTED:  ',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF868E96)),
                                      ),
                                      Text(
                                        '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year} at ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: borderColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Interactive Actions Section
                      if (!isResolved) ...[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: borderColor,
                                  offset: Offset(3, 3),
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
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: borderColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isOwner
                                      ? 'Mark this item as resolved if you recovered it or returned it to its owner.'
                                      : (isLost 
                                          ? 'Write comment below if you have any leads on where this item is.'
                                          : 'If this is your item, submit a claim request. The finder will review it.'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: borderColor.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                if (isOwner)
                                  ElevatedButton(
                                    onPressed: _isPerformingAction ? null : () => _markResolved(post.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tealAccent,
                                      foregroundColor: borderColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: const BorderSide(color: borderColor, width: 2),
                                    ),
                                    child: _isPerformingAction
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: borderColor),
                                          )
                                        : const Text('MARK AS RESOLVED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                  )
                                else if (!isLost)
                                  ElevatedButton(
                                    onPressed: _isPerformingAction ? null : () => _claimItem(post.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yellowAccent,
                                      foregroundColor: borderColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: const BorderSide(color: borderColor, width: 2),
                                    ),
                                    child: _isPerformingAction
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: borderColor),
                                          )
                                        : const Text('SUBMIT RECOVERY CLAIM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F3F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Leave a comment below if you have any details!',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF495057)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Comments Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          'Comments Thread',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: borderColor,
                          ),
                        ),
                      ),

                      // Comments list view
                      commentsAsyncValue.when(
                        data: (comments) {
                          if (comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No comments yet. Start the conversation!',
                                  style: TextStyle(
                                    color: borderColor.withOpacity(0.4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator(color: borderColor)),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Error: $err', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Bottom Comment Input Box
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: borderColor.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: borderColor, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isSubmittingComment ? null : () => _addComment(post.id),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: yellowAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: _isSubmittingComment
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: borderColor),
                              )
                            : const Icon(Icons.send_rounded, color: borderColor, size: 18),
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
            color: borderColor,
            strokeWidth: 3,
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
          ),
        ),
      ),
    );
  }
}
