import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/post_card.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFD93D); // Neo-brutalism Yellow
    const greenAccent = Color(0xFF4ECDC4); // Pastel Teal

    // Read feed states
    final categoryFilter = ref.watch(postsFilterCategoryProvider);
    final typeFilter = ref.watch(postsFilterTypeProvider);
    final postsAsync = ref.watch(postsProvider);

    final categories = ['All', 'Electronics', 'Keys', 'Clothing', 'Documents', 'Books', 'Other'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: borderColor, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: borderColor, size: 24),
            SizedBox(width: 8),
            Text(
              'TraceIt Feed',
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Profile Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: greenAccent,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: const Icon(Icons.person_rounded, color: borderColor, size: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: borderColor),
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Feed Type Selector Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) {
                    ref.read(postsSearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search items, locations...',
                    prefixIcon: const Icon(Icons.search_rounded, color: borderColor),
                    hintStyle: TextStyle(color: borderColor.withOpacity(0.3), fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: borderColor),
                ),
                const SizedBox(height: 12),

                // Type filter tabs (All, Lost, Found)
                Row(
                  children: [
                    _buildTypeButton(ref, 'All', typeFilter == 'All'),
                    const SizedBox(width: 8),
                    _buildTypeButton(ref, 'Lost', typeFilter == 'Lost'),
                    const SizedBox(width: 8),
                    _buildTypeButton(ref, 'Found', typeFilter == 'Found'),
                  ],
                ),
              ],
            ),
          ),

          // Horizontal Category Filter List
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEF),
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 40,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: borderColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your search or filters.',
                          style: TextStyle(
                            color: borderColor.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                  color: borderColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
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
                  color: borderColor,
                  strokeWidth: 3,
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: borderColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 2),
        ),
        elevation: 0,
        // Flat offset shadow
        label: const Row(
          children: [
            Icon(Icons.add_rounded, fontWeight: FontWeight.w900),
            SizedBox(width: 4),
            Text(
              'REPORT ITEM',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
    const borderColor = Color(0xFF1E1E1E);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(postsFilterTypeProvider.notifier).state = type;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.white : borderColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
