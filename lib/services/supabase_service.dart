import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../models/profile.dart';
import '../models/comment.dart';
import '../models/claim.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // --- Auth Section ---
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': username,
        'display_name': username,
        'name': username,
      },
    );

    // If signup is successful, we try to create a profile manually in case a database trigger is not present.
    // We wrap it in a try-catch because if a trigger is already present or if email confirmation is enabled
    // (making the client session unauthenticated), RLS policies will block the manual client insert.
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Safe to ignore: database trigger handled it or RLS blocked unauthenticated client insert
      }
    }

    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // --- Profiles Section ---
  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(Profile profile) async {
    await _client.from('profiles').upsert(profile.toJson());
  }

  // --- Posts Section ---
  Future<List<Post>> fetchPosts({String? category, String? type, String? searchQuery}) async {
    try {
      var query = _client.from('posts').select();

      if (category != null && category.toLowerCase() != 'all') {
        query = query.eq('category', category);
      }
      if (type != null && type.toLowerCase() != 'all') {
        query = query.eq('type', type.toLowerCase());
      }

      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      List<Post> posts = data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        posts = posts.where((post) {
          final query = searchQuery.toLowerCase();
          return post.title.toLowerCase().contains(query) ||
              post.description.toLowerCase().contains(query) ||
              post.location.toLowerCase().contains(query);
        }).toList();
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<Post?> fetchPostById(String postId) async {
    try {
      final data = await _client
          .from('posts')
          .select()
          .eq('id', postId)
          .maybeSingle();
      if (data == null) return null;
      return Post.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Stream<List<Post>> getPostsStream() {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Post.fromJson(map)).toList());
  }

  Future<void> createPost(Post post) async {
    await _client.from('posts').insert(post.toJson());
  }

  Future<void> updatePostStatus(String postId, String status) async {
    await _client.from('posts').update({'status': status}).eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  // --- Comments Section ---
  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final response = await _client
          .from('comments')
          .select('*, profiles(username)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Comment.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCommentsStream(String postId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true);
  }

  Future<void> addComment(String postId, String content) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }

  // --- Claims Section ---
  Future<List<Claim>> fetchClaimsForPost(String postId) async {
    try {
      final response = await _client.from('claims').select().eq('post_id', postId);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Claim.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Claim>> fetchClaimsByUser(String claimantId) async {
    try {
      final response = await _client.from('claims').select().eq('claimant_id', claimantId);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Claim.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createClaim(String postId) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('claims').insert({
      'post_id': postId,
      'claimant_id': userId,
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> updateClaimStatus(String claimId, String status) async {
    await _client.from('claims').update({'status': status}).eq('id', claimId);
  }

  Future<String?> uploadPostImage(String postId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExtension = filePath.split('.').last;
      final path = 'posts/$postId.$fileExtension';
      
      // Attempt upload to 'images' bucket
      await _client.storage.from('images').upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      
      final imageUrl = _client.storage.from('images').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      // Fallback: try 'post-images' bucket if 'images' fails
      try {
        final file = File(filePath);
        final fileExtension = filePath.split('.').last;
        final path = 'posts/$postId.$fileExtension';
        
        await _client.storage.from('post-images').upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
        
        final imageUrl = _client.storage.from('post-images').getPublicUrl(path);
        return imageUrl;
      } catch (err) {
        throw Exception('Failed to upload image to Supabase Storage: $e');
      }
    }
  }
}
