import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/post_card.dart';
import '../models/claim.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Claim> _userClaims = [];
  bool _isLoadingClaims = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserClaims();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserClaims() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoadingClaims = true;
    });

    try {
      final claims = await ref.read(supabaseServiceProvider).fetchClaimsByUser(user.id);
      setState(() {
        _userClaims = claims;
      });
    } catch (e) {
      // Gracefully handle or log error
    } finally {
      setState(() {
        _isLoadingClaims = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1E1E1E);
    const yellowAccent = Color(0xFFFFD93D);

    final currentUser = ref.watch(currentUserProvider);
    final profileAsyncValue = ref.watch(currentProfileProvider);
    final postsAsyncValue = ref.watch(postsProvider);

    final userInitial = currentUser?.email != null && currentUser!.email!.isNotEmpty
        ? currentUser.email![0].toUpperCase()
        : 'U';

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
          'My Dashboard',
          style: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Profile Details Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Flat Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: yellowAccent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: borderColor,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: borderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Profile Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileAsyncValue.when(
                            data: (profile) => Text(
                              profile?.username ?? 'User Profile',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: borderColor,
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 16,
                              width: 80,
                              child: LinearProgressIndicator(color: borderColor, backgroundColor: Colors.transparent),
                            ),
                            error: (_, __) => const Text(
                              'TraceIt User',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.email ?? 'anonymous@traceit.org',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: borderColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign Out Button
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(supabaseServiceProvider).signOut();
                    if (mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                    side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'SIGN OUT FROM ACCOUNT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar Selector
          Container(
            decoration: const BoxDecoration(
            color: Colors.white, // <-- Moved inside
            border: Border(
            top: BorderSide(color: borderColor, width: 1.5),
            bottom: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
              child: TabBar(
              controller: _tabController,
              labelColor: borderColor,
              unselectedLabelColor: borderColor.withOpacity(0.4),
              indicatorColor: borderColor,
              indicatorWeight: 3.5,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'MY REPORTS'),
                Tab(text: 'MY RECOVERY CLAIMS'),
              ],
            ),
          ),

          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: User's reported items
                postsAsyncValue.when(
                  data: (posts) {
                    final userPosts = posts.where((p) => p.userId == currentUser?.id).toList();

                    if (userPosts.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.assignment_late_outlined,
                        title: 'No reports filed',
                        subtitle: 'Tap Report Item on the feed page to submit a new report.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return PostCard(
                          post: post,
                          onTap: () {
                            Navigator.pushNamed(context, '/details', arguments: post.id);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: borderColor)),
                  error: (err, __) => Center(child: Text('Error loading posts: $err')),
                ),

                // Tab 2: User's submitted claims
                _isLoadingClaims
                    ? const Center(child: CircularProgressIndicator(color: borderColor))
                    : _userClaims.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.shield_outlined,
                            title: 'No claims submitted',
                            subtitle: "Select a 'found' item reported by someone else to file a claim.",
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _userClaims.length,
                            itemBuilder: (context, index) {
                              final claim = _userClaims[index];
                              final statusColor = claim.status == 'accepted'
                                  ? const Color(0xFF2B8A3E)
                                  : (claim.status == 'rejected' ? const Color(0xFFC92A2A) : const Color(0xFFE67E22));
                              
                              final statusBg = claim.status == 'accepted'
                                  ? const Color(0xFFD3F9D8)
                                  : (claim.status == 'rejected' ? const Color(0xFFFFE3E3) : const Color(0xFFFFEC99));

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(color: borderColor, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Claim ID: ${claim.id.substring(0, 8)}...',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: borderColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Submitted on: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: borderColor.withOpacity(0.5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderColor, width: 1.5),
                                      ),
                                      child: Text(
                                        claim.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    const borderColor = Color(0xFF1E1E1E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Icon(icon, size: 36, color: borderColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: borderColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
