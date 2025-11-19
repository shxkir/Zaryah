import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/profile_avatar.dart';
import 'chat_screen.dart';

class UserProfileDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user.profile;
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('Profile not available')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: CustomScrollView(
        slivers: [
          // Stunning app bar with gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF000000),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.3),
                          const Color(0xFF000000),
                        ],
                      ),
                    ),
                  ),
                  // Profile content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Avatar with stunning glow effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 4,
                            ),
                          ),
                          child: ProfileAvatar(
                            imageUrl: profile.displayPicture,
                            name: profile.name,
                            size: 120,
                            backgroundColor: const Color(0xFFFFD700),
                            textColor: const Color(0xFF000000),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFB700),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                partnerId: user.id,
                                partnerName: profile.name,
                                partnerProfilePicture: profile.displayPicture,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message_rounded,
                              color: Color(0xFF000000),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Send Message',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bio section
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    _buildSectionTitle('About'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      content: profile.bio!,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Professional Info
                  _buildSectionTitle('Professional'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Occupation',
                          profile.occupation,
                          Icons.work_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Age',
                          '${profile.age} years',
                          Icons.cake_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.school_outlined,
                    title: 'Education',
                    content: profile.educationLevel,
                  ),
                  const SizedBox(height: 24),

                  // Learning Info
                  _buildSectionTitle('Learning Journey'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.flag_outlined,
                    title: 'Goals',
                    content: profile.learningGoals,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Learning Style',
                    content: profile.learningStyle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Hours/Week',
                          '${profile.availableHoursPerWeek}h',
                          Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Pace',
                          profile.learningPace,
                          Icons.speed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subjects
                  if (profile.subjects.isNotEmpty) ...[
                    _buildSectionTitle('Subjects of Interest'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.subjects.map((subject) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withOpacity(0.2),
                                const Color(0xFFFFD700).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            subject,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Strengths & Weaknesses
                  _buildSectionTitle('Strengths & Development Areas'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.star_outline,
                    title: 'Strengths',
                    content: profile.strengths,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.trending_up,
                    title: 'Areas to Improve',
                    content: profile.weaknesses,
                  ),
                  const SizedBox(height: 24),

                  // Experience & Challenges
                  _buildSectionTitle('Experience & Challenges'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.history,
                    title: 'Previous Experience',
                    content: profile.previousExperience,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.psychology_outlined,
                    title: 'Specific Challenges',
                    content: profile.specificChallenges,
                  ),
                  const SizedBox(height: 24),

                  // Motivation
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Motivation',
                          profile.motivationLevel,
                          Icons.local_fire_department,
                          color: _getMotivationColor(profile.motivationLevel),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFFB700),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    String? title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? const Color(0xFFFFD700)).withOpacity(0.15),
            (color ?? const Color(0xFFFFD700)).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? const Color(0xFFFFD700)).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? const Color(0xFFFFD700),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFFFFD700),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getMotivationColor(String motivation) {
    switch (motivation.toLowerCase()) {
      case 'high':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFFD700);
      case 'low':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFFFD700);
    }
  }
}
