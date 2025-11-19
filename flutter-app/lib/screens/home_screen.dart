import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import '../widgets/profile_avatar.dart';
import 'chatbot_screen.dart';
import 'community_screen.dart';
import 'map_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _apiService = ApiService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getCurrentProfile();
      if (mounted) {
        setState(() {
          _user = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      // Silent fail - dashboard will show generic welcome
    }
  }

  List<Widget> get _screens => [
        DashboardScreen(user: _user),
        const MapScreen(),
        const ChatbotScreen(),
        const MessagesScreen(),
        const CommunityScreen(),
        const ServicesScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: LuxuryColors.secondaryBackground,
        selectedItemColor: LuxuryColors.primaryGold,
        unselectedItemColor: LuxuryColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final UserModel? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _syncUserName(widget.user);
    _loadDashboardData();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user?.profile?.name != oldWidget.user?.profile?.name) {
      _syncUserName(widget.user);
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _syncUserName(UserModel? user) {
    final providedName = user?.profile?.name;
    if (providedName != null && providedName.isNotEmpty) {
      if (_userName != providedName) {
        setState(() {
          _userName = providedName;
        });
      }
    } else {
      _fetchUserName();
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final profile = await _apiService.getCurrentProfile();
      final fetchedName = profile['profile']?['name'] as String?;
      if (mounted && fetchedName != null && fetchedName.isNotEmpty) {
        setState(() {
          _userName = fetchedName;
        });
      }
    } catch (_) {
      // Ignore; we'll fall back to generic label
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = _userName != null && _userName!.isNotEmpty
        ? _userName!.split(' ').first
        : 'User';
    final String greeting = _getGreeting();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GoldGradientBackground(
        child: RefreshIndicator(
          color: LuxuryColors.primaryGold,
          onRefresh: _loadDashboardData,
          child: CustomScrollView(
            slivers: [
              // Luxury App Bar
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: LuxuryColors.secondaryBackground,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LuxuryColors.cardGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '$greeting, $firstName',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: LuxuryColors.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Logout button
                            GoldIconButton(
                              icon: Icons.logout,
                              size: 28,
                              tooltip: 'Logout',
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: LuxuryColors.cardBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                        color: LuxuryColors.borderGold,
                                        width: 1,
                                      ),
                                    ),
                                    title: Text(
                                      'Logout',
                                      style: LuxuryTextStyles.h2,
                                    ),
                                    content: Text(
                                      'Are you sure you want to logout?',
                                      style: LuxuryTextStyles.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: LuxuryTextStyles.bodyMedium.copyWith(
                                            color: LuxuryColors.mutedText,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Clear any stored tokens/data
                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                            '/login',
                                            (route) => false,
                                          );
                                        },
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(color: LuxuryColors.errorGold),
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
                    ),
                  ),
                ),
              ),

              // Content
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: LuxuryColors.primaryGold),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        _buildSectionTitle('Your Stats'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Users',
                                '${_dashboardData?['stats']?['totalUsers'] ?? 0}',
                                Icons.people_rounded,
                                LuxuryColors.primaryGold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Messages',
                                '${_dashboardData?['stats']?['unreadMessages'] ?? 0}',
                                Icons.message_rounded,
                                LuxuryColors.softGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Conversations',
                                '${_dashboardData?['stats']?['totalConversations'] ?? 0}',
                                Icons.chat_bubble_rounded,
                                LuxuryColors.primaryGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Quick Actions
                        _buildSectionTitle('Quick Actions'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                'Chat AI',
                                Icons.smart_toy,
                                LuxuryColors.primaryGold,
                                () {
                                  // Switch to chatbot tab (index 2)
                                  final homeState =
                                      context.findAncestorStateOfType<
                                          _HomeScreenState>();
                                  homeState?.setState(() {
                                    homeState._currentIndex = 2;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'Browse Users',
                                Icons.people,
                                LuxuryColors.softGold,
                                () {
                                  // Switch to community tab (index 4)
                                  final homeState =
                                      context.findAncestorStateOfType<
                                          _HomeScreenState>();
                                  homeState?.setState(() {
                                    homeState._currentIndex = 4;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                'Messages',
                                Icons.message,
                                LuxuryColors.primaryGold,
                                () {
                                  // Switch to messages tab (index 3)
                                  final homeState =
                                      context.findAncestorStateOfType<
                                          _HomeScreenState>();
                                  homeState?.setState(() {
                                    homeState._currentIndex = 3;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'Edit Profile',
                                Icons.edit,
                                LuxuryColors.softGold,
                                () {
                                  // Switch to profile tab (index 6)
                                  final homeState =
                                      context.findAncestorStateOfType<
                                          _HomeScreenState>();
                                  homeState?.setState(() {
                                    homeState._currentIndex = 6;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Recent Users
                        if (_dashboardData?['recentUsers'] != null &&
                            (_dashboardData!['recentUsers'] as List)
                                .isNotEmpty) ...[
                          _buildSectionTitle('Recent Chats'),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  (_dashboardData!['recentUsers'] as List)
                                      .length,
                              itemBuilder: (context, index) {
                                final user = (_dashboardData!['recentUsers']
                                    as List)[index];
                                return _buildRecentUserCard(user);
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Suggested Users
                        if (_dashboardData?['suggestedUsers'] != null &&
                            (_dashboardData!['suggestedUsers'] as List)
                                .isNotEmpty) ...[
                          _buildSectionTitle('Suggested Connections'),
                          const SizedBox(height: 16),
                          ...(_dashboardData!['suggestedUsers'] as List)
                              .map((user) {
                            return _buildSuggestedUserCard(user);
                          }),
                          const SizedBox(height: 32),
                        ],

                        // Trending Topics
                        if (_dashboardData?['trendingTopics'] != null &&
                            (_dashboardData!['trendingTopics'] as List)
                                .isNotEmpty) ...[
                          _buildSectionTitle('Trending Topics'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (_dashboardData!['trendingTopics'] as List)
                                    .map((topic) {
                              return _buildTrendingChip(
                                topic['topic'],
                                topic['count'],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return GoldSectionHeader(
      text: title,
      padding: const EdgeInsets.symmetric(vertical: 0),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return GoldStatsCard(
      label: label,
      value: value,
      icon: icon,
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GoldCard(
      onTap: onTap,
      showGlow: true,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: LuxuryColors.primaryGold, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: LuxuryTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUserCard(Map<String, dynamic> user) {
    final profile = user['profile'];
    final name = profile?['name'] ?? 'Unknown';
    final profilePictureUrl = profile?['profilePictureUrl'] as String?;
    final profilePicture = profile?['profilePicture'] as String?;
    final displayPicture = profilePictureUrl ?? profilePicture;

    return GoldCard(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      showGlow: true,
      onTap: () {
        // Navigate to user profile or chat
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoldAvatarFrame(
            imageUrl: displayPicture,
            initials: name.split(' ').map((n) => n[0]).take(2).join(),
            size: 60,
            borderWidth: 2,
          ),
          const SizedBox(height: 8),
          Text(
            name.split(' ').first,
            style: LuxuryTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUserCard(Map<String, dynamic> user) {
    final profile = user['profile'];
    final name = profile?['name'] ?? 'Unknown';
    final occupation = profile?['occupation'] ?? '';
    final city = profile?['city'] ?? '';
    final country = profile?['country'] ?? '';
    final userId = user['id'];
    final profilePictureUrl = profile?['profilePictureUrl'] as String?;
    final profilePicture = profile?['profilePicture'] as String?;
    final displayPicture = profilePictureUrl ?? profilePicture;

    // Build location string
    String locationString = '';
    if (city.isNotEmpty && country.isNotEmpty) {
      locationString = '$city, $country';
    } else if (city.isNotEmpty) {
      locationString = city;
    } else if (country.isNotEmpty) {
      locationString = country;
    }

    return GoldCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      showGlow: true,
      child: Row(
        children: [
          GoldAvatarFrame(
            imageUrl: displayPicture,
            initials: name.split(' ').map((n) => n[0]).take(2).join(),
            size: 48,
            borderWidth: 2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: LuxuryTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (locationString.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: LuxuryColors.softGold,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationString,
                          style: LuxuryTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (occupation.isNotEmpty)
                  Text(
                    occupation,
                    style: LuxuryTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GoldIconButton(
            icon: Icons.person_add_rounded,
            size: 20,
            onPressed: () async {
              try {
                // Call API to add friend
                await _apiService.sendConnectionRequest(userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connection request sent to $name!'),
                      backgroundColor: LuxuryColors.successGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: LuxuryColors.errorGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingChip(String topic, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LuxuryColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LuxuryColors.borderGold),
        boxShadow: LuxuryColors.goldGlow(opacity: 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            color: LuxuryColors.primaryGold,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            topic,
            style: LuxuryTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: LuxuryColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: LuxuryColors.mainBackground,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
