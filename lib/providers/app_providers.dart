import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/post.dart';
import '../models/profile.dart';
import '../models/comment.dart';

// Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseServiceProvider).authStateChanges;
});

// Current User Provider (listens to auth state changes to stay fresh)
final currentUserProvider = Provider<User?>((ref) {
  // We trigger rebuilds on auth state changes
  ref.watch(authStateProvider);
  return ref.watch(supabaseServiceProvider).currentUser;
});

// User Profile Provider (fetches profile of a specific user)
final profileProvider = FutureProvider.family<Profile?, String>((ref, userId) async {
  return ref.watch(supabaseServiceProvider).getProfile(userId);
});

// Current Logged In Profile Provider
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(supabaseServiceProvider).getProfile(user.id);
});

// Feed Filtering Providers
final postsFilterCategoryProvider = StateProvider<String>((ref) => 'All');
final postsFilterTypeProvider = StateProvider<String>((ref) => 'All'); // 'All', 'Lost', 'Found'
final postsSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Posts Provider
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final category = ref.watch(postsFilterCategoryProvider);
  final type = ref.watch(postsFilterTypeProvider);
  final search = ref.watch(postsSearchQueryProvider);
  
  // Re-run this future whenever filters change
  return service.fetchPosts(
    category: category,
    type: type,
    searchQuery: search,
  );
});

// Post Details Provider (fetch single post by ID)
final postDetailsProvider = FutureProvider.family<Post?, String>((ref, postId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.fetchPostById(postId);
});

// Comments Provider for a post
final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  return ref.watch(supabaseServiceProvider).fetchComments(postId);
});
