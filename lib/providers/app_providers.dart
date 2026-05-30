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
// Filtered Posts Provider (REAL-TIME ENABLED)
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final category = ref.watch(postsFilterCategoryProvider);
  final type = ref.watch(postsFilterTypeProvider);
  final search = ref.watch(postsSearchQueryProvider);
  
  // 1. Subscribe to live changes on the 'posts' table
  final channel = service.client.channel('public:posts_feed');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'posts',
    callback: (payload) {
      // 2. When a change happens, tell Riverpod to auto-refresh the UI
      ref.invalidateSelf(); 
    }
  ).subscribe();

  // 3. Clean up the listener when leaving the screen
  ref.onDispose(() {
    service.client.removeChannel(channel);
  });

  return service.fetchPosts(
    category: category,
    type: type,
    searchQuery: search,
  );
});

// Post Details Provider (REAL-TIME ENABLED)
final postDetailsProvider = FutureProvider.family<Post?, String>((ref, postId) async {
  final service = ref.watch(supabaseServiceProvider);
  
  final channel = service.client.channel('public:post_details_$postId');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'posts',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'id',
      value: postId,
    ),
    callback: (payload) {
      ref.invalidateSelf();
    }
  ).subscribe();

  ref.onDispose(() {
    service.client.removeChannel(channel);
  });

  return service.fetchPostById(postId);
});

// Comments Provider (REAL-TIME ENABLED)
final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final service = ref.watch(supabaseServiceProvider);

  final channel = service.client.channel('public:comments_$postId');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'comments',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'post_id',
      value: postId,
    ),
    callback: (payload) {
      ref.invalidateSelf();
    }
  ).subscribe();

  ref.onDispose(() {
    service.client.removeChannel(channel);
  });

  return service.fetchComments(postId);
});