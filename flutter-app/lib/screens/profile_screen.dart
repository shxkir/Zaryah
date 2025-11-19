import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/animated_components.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = true;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _inAppNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _apiService.getCurrentProfile();
      setState(() {
        _user = UserModel.fromJson(userData);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GoldAppBar(
        title: 'Profile',
        actions: [
          if (_user != null)
            GoldIconButton(
              icon: Icons.edit,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  LuxuryPageRoute(
                    page: EditProfileScreen(user: _user!),
                  ),
                );
                if (result == true) {
                  _loadProfile(); // Refresh profile after edit
                }
              },
            ),
        ],
      ),
      body: GoldGradientBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: LuxuryColors.primaryGold),
              )
            : _user == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load profile',
                          style: LuxuryTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        GoldButton(
                          text: 'Retry',
                          onPressed: _loadProfile,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: LuxuryColors.primaryGold,
                    onRefresh: _loadProfile,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              GoldAvatarFrame(
                                imageUrl: _user!.profile?.displayPicture,
                                initials: (_user!.profile?.name ?? 'U')
                                    .split(' ')
                                    .map((n) => n[0])
                                    .take(2)
                                    .join(),
                                size: 120,
                                borderWidth: 4,
                                showGlow: true,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _user!.profile?.name ?? 'No name',
                                style: LuxuryTextStyles.h1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user!.email,
                                style: LuxuryTextStyles.bodyMedium.copyWith(
                                  color: LuxuryColors.mutedText,
                                ),
                              ),
                            if (_user!.profile?.bio != null && _user!.profile!.bio!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: LuxuryColors.cardBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _user!.profile!.bio!,
                                  style: LuxuryTextStyles.bodyMedium.copyWith(
                                    color: LuxuryColors.mutedText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Quick Stats
                      if (_user!.profile != null) ...[
                        GoldSectionHeader(
                          text: 'Quick Stats',
                          icon: Icons.bar_chart,
                          padding: const EdgeInsets.only(bottom: 16),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Age',
                                _user!.profile!.age.toString(),
                                Icons.cake,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Hours/Week',
                                _user!.profile!.availableHoursPerWeek.toString(),
                                Icons.access_time,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          'Occupation',
                          _user!.profile!.occupation,
                          Icons.work,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          'Education',
                          _user!.profile!.educationLevel,
                          Icons.school,
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Settings Section
                      GoldSectionHeader(
                        text: 'Notifications & Privacy',
                        icon: Icons.notifications_outlined,
                        padding: const EdgeInsets.only(bottom: 12),
                      ),
                      _buildToggleTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Remind me about chats and progress updates',
                        value: _pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _pushNotificationsEnabled = value);
                        },
                      ),
                      _buildToggleTile(
                        icon: Icons.mail_outline,
                        title: 'Email Updates',
                        subtitle: 'Weekly recaps and new learning suggestions',
                        value: _emailNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _emailNotificationsEnabled = value);
                        },
                      ),
                      _buildToggleTile(
                        icon: Icons.phone_android,
                        title: 'In-app Alerts',
                        subtitle: 'Show alerts when mentors reply',
                        value: _inAppNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _inAppNotificationsEnabled = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      GoldSectionHeader(
                        text: 'Support & Security',
                        icon: Icons.security,
                        padding: const EdgeInsets.only(bottom: 12),
                      ),
                      _buildSupportTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Controls',
                        subtitle: 'Manage data sharing & visibility',
                        actionLabel: 'Open',
                        onTap: () {
                          _showInfoSheet(
                            title: 'Privacy Controls',
                            body:
                                'Control which learning stats are visible to mentors and classmates. You can anonymize sensitive details any time.',
                          );
                        },
                      ),
                      _buildSupportTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Chat with the Zaryah support team',
                        actionLabel: 'Contact',
                        onTap: _showHelpSupport,
                      ),
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Zaryah',
                            applicationVersion: '1.0.0',
                            applicationLegalese: 'AI-Powered Personalized Learning',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        isDestructive: true,
                        onTap: _logout,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GoldCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      showGlow: true,
      child: Column(
        children: [
          Icon(icon, color: LuxuryColors.primaryGold, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: LuxuryTextStyles.h2.copyWith(
              color: LuxuryColors.headingText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: LuxuryTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return GoldCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Icon(icon, color: LuxuryColors.primaryGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: LuxuryTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: LuxuryTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GoldCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? LuxuryColors.errorGold : LuxuryColors.primaryGold,
        ),
        title: Text(
          title,
          style: LuxuryTextStyles.bodyLarge.copyWith(
            color: isDestructive ? LuxuryColors.errorGold : LuxuryColors.headingText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? LuxuryColors.errorGold : LuxuryColors.mutedText,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GoldCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: LuxuryColors.primaryGold,
        secondary: Icon(icon, color: LuxuryColors.primaryGold),
        title: Text(
          title,
          style: LuxuryTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: LuxuryTextStyles.bodyMedium.copyWith(
            color: LuxuryColors.mutedText,
          ),
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return GoldCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      showGlow: true,
      child: ListTile(
        leading: Icon(icon, color: LuxuryColors.primaryGold),
        title: Text(
          title,
          style: LuxuryTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: LuxuryTextStyles.bodyMedium.copyWith(
            color: LuxuryColors.mutedText,
            height: 1.3,
          ),
        ),
        trailing: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: LuxuryColors.primaryGold,
          ),
          onPressed: onTap,
          child: Text(actionLabel),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showInfoSheet({required String title, required String body}) {
    GoldBottomSheet.show(
      context: context,
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: LuxuryTextStyles.bodyLarge.copyWith(
                color: LuxuryColors.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: GoldButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport() {
    _showInfoSheet(
      title: 'Help & Support',
      body:
          'Email us at support@zaryah.ai or chat with a mentor for real-time assistance. We typically respond within 24 hours.',
    );
  }
}
