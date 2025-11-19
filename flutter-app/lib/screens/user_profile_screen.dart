import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/initials_helper.dart';
import '../widgets/simple_avatar.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _apiService.getUserById(widget.userId);
      setState(() {
        _user = UserModel.fromJson(userData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SimpleAvatar(
                          size: 120,
                          backgroundColor: const Color(0xFFFFD700),
                          child: Text(
                            initialsFromName(_user!.profile?.name),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _user!.profile?.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _user!.email,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  partnerId: _user!.id,
                                  partnerName: _user!.profile?.name ?? _user!.email,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Send Message'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSection('Basic Information', [
                        _buildInfoRow('Age', '${_user!.profile?.age ?? 'N/A'}'),
                        _buildInfoRow('Occupation', _user!.profile?.occupation ?? 'N/A'),
                        _buildInfoRow('Education', _user!.profile?.educationLevel ?? 'N/A'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Learning Profile', [
                        _buildInfoRow('Learning Style', _user!.profile?.learningStyle ?? 'N/A'),
                        _buildInfoRow('Learning Pace', _user!.profile?.learningPace ?? 'N/A'),
                        _buildInfoRow('Motivation Level', _user!.profile?.motivationLevel ?? 'N/A'),
                        _buildInfoRow('Hours/Week', '${_user!.profile?.availableHoursPerWeek ?? 'N/A'}'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Goals & Interests', [
                        _buildInfoRow('Learning Goals', _user!.profile?.learningGoals ?? 'N/A'),
                        _buildInfoRow('Subjects', _user!.profile?.subjects.join(', ') ?? 'N/A'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Skills & Experience', [
                        _buildInfoRow('Strengths', _user!.profile?.strengths ?? 'N/A'),
                        _buildInfoRow('Challenges', _user!.profile?.weaknesses ?? 'N/A'),
                        _buildInfoRow('Previous Experience', _user!.profile?.previousExperience ?? 'N/A'),
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
