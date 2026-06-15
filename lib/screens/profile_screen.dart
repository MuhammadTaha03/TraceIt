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
    const primaryColor = Color(0xFF1A73E8);
    const onSurface = Color(0xFF191C1D);
    const outlineColor = Color(0xFF727785);
    const outlineVariant = Color(0xFFE1E3E4);
    const backgroundColor = Color(0xFFF8F9FA);

    final currentUser = ref.watch(currentUserProvider);
    final profileAsyncValue = ref.watch(currentProfileProvider);
    final postsAsyncValue = ref.watch(postsProvider);

    final userInitial = currentUser?.email != null && currentUser!.email!.isNotEmpty
        ? currentUser.email![0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Dashboard'),
      ),
      body: Column(
        children: [
          // Profile Details Header Card
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // M3 Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Profile Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileAsyncValue.when(
                            data: (profile) => Text(
                              profile?.username ?? 'User Profile',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 16,
                              width: 80,
                              child: LinearProgressIndicator(color: primaryColor, backgroundColor: Colors.transparent),
                            ),
                            error: (_, __) => const Text(
                              'TraceIt User',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.email ?? 'anonymous@traceit.org',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: outlineColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(supabaseServiceProvider).signOut();
                    if (mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFBA1A1A),
                    side: const BorderSide(color: outlineVariant, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Sign Out from Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: outlineVariant, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: outlineColor,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: primaryColor.withOpacity(0.1),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'MY REPORTS'),
                Tab(text: 'MY CLAIMS'),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
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
                  loading: () => const Center(child: CircularProgressIndicator(color: primaryColor)),
                  error: (err, __) => Center(child: Text('Error loading posts: $err')),
                ),

                // Tab 2: User's submitted claims
                _isLoadingClaims
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : _userClaims.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.shield_outlined,
                            title: 'No claims submitted',
                            subtitle: "Select a 'found' item reported by someone else to file a claim.",
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: _userClaims.length,
                            itemBuilder: (context, index) {
                              final claim = _userClaims[index];
                              final statusColor = claim.status == 'accepted'
                                  ? const Color(0xFF002108)
                                  : (claim.status == 'rejected' ? const Color(0xFF93000A) : const Color(0xFF4D3A00));
                              
                              final statusBg = claim.status == 'accepted'
                                  ? const Color(0xFFD3F9D8)
                                  : (claim.status == 'rejected' ? const Color(0xFFFFDAD6) : const Color(0xFFFFEC99));

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: outlineVariant, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
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
                                            'Claim ID: ${claim.id.substring(0, 8).toUpperCase()}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Submitted on: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              color: outlineColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        claim.status.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
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
    const onSurface = Color(0xFF191C1D);
    const outlineColor = Color(0xFF727785);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: outlineColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: outlineColor,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
