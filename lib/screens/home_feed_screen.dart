import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/post_card.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF1A73E8);
    const onSurface = Color(0xFF191C1D);
    const outlineColor = Color(0xFF727785);
    const backgroundColor = Color(0xFFF8F9FA);

    // Read feed states
    final categoryFilter = ref.watch(postsFilterCategoryProvider);
    final typeFilter = ref.watch(postsFilterTypeProvider);
    final postsAsync = ref.watch(postsProvider);

    final categories = ['All', 'Electronics', 'Keys', 'Clothing', 'Documents', 'Books', 'Other'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, color: primaryColor, size: 24),
            SizedBox(width: 8),
            Text(
              'TraceIt Feed',
              style: TextStyle(
                fontFamily: 'Inter',
                color: onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFD8E2FF), // primary-fixed
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF001A41), size: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: outlineColor),
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Feed Type Selector Container
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) {
                      ref.read(postsSearchQueryProvider.notifier).state = val;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search items, locations...',
                      prefixIcon: Icon(Icons.search_rounded, color: outlineColor),
                      fillColor: Color(0xFFFFFFFF), // crisp white search on grey bg
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type filter tabs (All, Lost, Found)
                  Row(
                    children: [
                      _buildTypeButton(ref, 'All', typeFilter == 'All'),
                      const SizedBox(width: 12),
                      _buildTypeButton(ref, 'Lost', typeFilter == 'Lost'),
                      const SizedBox(width: 12),
                      _buildTypeButton(ref, 'Found', typeFilter == 'Found'),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Category Filter List
            Container(
              height: 48,
              color: Colors.transparent,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == categoryFilter;
                  return GestureDetector(
                    onTap: () {
                      ref.read(postsFilterCategoryProvider.notifier).state = category;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : const Color(0xFFE1E3E4), // surface-variant
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF414754),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),

            // Feed List
            Expanded(
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 40,
                              color: outlineColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No items found',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try adjusting your search or filters.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: outlineColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(postsProvider);
                    },
                    color: primaryColor,
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () {
                            Navigator.pushNamed(
                              context, 
                              '/details', 
                              arguments: post.id,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // squircle
        ),
        elevation: 3, // soft Level 3 shadow
        label: const Row(
          children: [
            Icon(Icons.add_rounded, fontWeight: FontWeight.w600),
            SizedBox(width: 6),
            Text(
              'Report Item',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
      ),
    );
  }

  Widget _buildTypeButton(WidgetRef ref, String type, bool isSelected) {
    const primaryColor = Color(0xFF1A73E8);
    const onSurface = Color(0xFF191C1D);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(postsFilterTypeProvider.notifier).state = type;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xFFE1E3E4),
              width: 1,
            ),
          ),
          child: Text(
            type,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
