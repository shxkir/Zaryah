import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/animated_components.dart';
import '../widgets/luxury_components.dart';
import '../theme/luxury_theme.dart';
import 'chat_screen.dart';
import 'user_profile_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _apiService = ApiService();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedCountry = 'All Countries';
  List<String> _availableCountries = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final usersData = await _apiService.getAllUsers();
      setState(() {
        _allUsers = usersData.map((data) => UserModel.fromJson(data)).toList();
        _filteredUsers = _allUsers;
        _extractCountries();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  Future<void> _loadUsersByCountry(String country) async {
    setState(() => _isLoading = true);
    try {
      final usersData = await _apiService.getUsersByCountry(country);
      setState(() {
        _allUsers = usersData.map((data) => UserModel.fromJson(data)).toList();
        _filteredUsers = _allUsers;
        _selectedCountry = country;
        _isLoading = false;
        // Re-apply search filter if active
        if (_searchController.text.isNotEmpty) {
          _filterUsers(_searchController.text);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users from $country: $e')),
        );
      }
    }
  }

  void _extractCountries() {
    final predefinedCountries = [
      'All Countries',
      'India',
      'Australia',
      'United Arab Emirates',
      'United States',
      'United Kingdom',
      'Singapore',
      'Malaysia',
      'Saudi Arabia',
    ];

    // Extract unique countries from user data
    final userCountries = _allUsers
        .where((user) => user.profile?.country != null && user.profile!.country!.isNotEmpty)
        .map((user) => user.profile!.country!)
        .toSet()
        .toList();

    // Merge and sort
    final allCountries = {...predefinedCountries, ...userCountries}.toList();
    allCountries.sort((a, b) {
      if (a == 'All Countries') return -1;
      if (b == 'All Countries') return 1;
      return a.compareTo(b);
    });

    setState(() {
      _availableCountries = allCountries;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = user.profile?.name.toLowerCase() ?? '';
          final occupation = user.profile?.occupation.toLowerCase() ?? '';
          final education = user.profile?.educationLevel.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
                 occupation.contains(searchLower) ||
                 education.contains(searchLower);
        }).toList();
      }

      // Apply category filter
      if (_selectedFilter != 'All') {
        _filteredUsers = _filteredUsers.where((user) {
          switch (_selectedFilter) {
            case 'Students':
              return user.profile?.educationLevel.toLowerCase().contains('student') ?? false;
            case 'Professionals':
              return user.profile?.occupation.toLowerCase() != 'student';
            case 'Active':
              return (user.profile?.motivationLevel.toLowerCase() ?? '') == 'high';
            default:
              return true;
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFF000000),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Community',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          Text(
                            '${_filteredUsers.length} Learners',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search bar with stunning design
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterUsers,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name, occupation, education...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterUsers('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Country filter dropdown
                  if (_availableCountries.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.public,
                          color: LuxuryColors.primaryGold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Country:',
                          style: LuxuryTextStyles.bodyMedium.copyWith(
                            color: LuxuryColors.primaryGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GoldDropdown<String>(
                            value: _selectedCountry,
                            items: _availableCountries,
                            onChanged: (String? country) {
                              if (country != null) {
                                if (country == 'All Countries') {
                                  _loadUsers();
                                } else {
                                  _loadUsersByCountry(country);
                                }
                              }
                            },
                            itemLabel: (country) => country,
                          ),
                        ),
                      ],
                    ),
                  if (_availableCountries.isNotEmpty) const SizedBox(height: 16),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Students', 'Professionals', 'Active'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                                _filterUsers(_searchController.text);
                              });
                            },
                            backgroundColor: const Color(0xFF1A1A1A),
                            selectedColor: const Color(0xFFFFD700),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFFFD700).withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Users list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No users found',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFFFD700),
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final profile = user.profile;
    if (profile == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0D0D0D),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              LuxuryPageRoute(
                page: UserProfileDetailScreen(user: user),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with gold ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ProfileAvatar(
                    imageUrl: profile.displayPicture,
                    name: profile.name,
                    size: 64,
                    backgroundColor: const Color(0xFFFFD700),
                    textColor: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(width: 16),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location (City, Country)
                      if (profile.formattedLocation.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                profile.formattedLocation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      // Occupation/Role
                      if (profile.occupation.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              size: 14,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                profile.occupation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      // Education Level
                      if (profile.educationLevel.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                profile.educationLevel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Message button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFB700),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          LuxuryPageRoute(
                            page: ChatScreen(
                              partnerId: user.id,
                              partnerName: profile.name,
                              partnerProfilePicture: profile.displayPicture,
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.message_rounded,
                          color: Color(0xFF000000),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
