import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import '../widgets/animated_components.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Auto-refresh conversations every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadConversations(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final conversations = await _apiService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conversations: $e')),
        );
      }
    }
  }

  String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GoldGradientBackground(
        child: SafeArea(
        child: Column(
          children: [
            // Stunning header
            Container(
              decoration: BoxDecoration(
                gradient: LuxuryColors.cardGradient,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LuxuryColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: LuxuryColors.borderGold,
                      ),
                    ),
                    child: Icon(
                      Icons.message_rounded,
                      color: LuxuryColors.mainBackground,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: LuxuryTextStyles.h1.copyWith(fontSize: 28),
                      ),
                      Text(
                        '${_conversations.length} ${_conversations.length == 1 ? 'conversation' : 'conversations'}',
                        style: LuxuryTextStyles.bodyMedium.copyWith(
                          color: LuxuryColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GoldIconButton(
                    icon: Icons.refresh,
                    onPressed: () => _loadConversations(),
                  ),
                ],
              ),
            ),

            // Conversations list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: LuxuryColors.primaryGold),
                    )
                  : _conversations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: LuxuryColors.primaryGold,
                          onRefresh: () => _loadConversations(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = _conversations[index];
                              return _buildConversationCard(conversation);
                            },
                          ),
                        ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LuxuryColors.primaryGold.withOpacity(0.2),
                  LuxuryColors.primaryGold.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.message_outlined,
              size: 80,
              color: LuxuryColors.primaryGold.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet',
            style: LuxuryTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation from the Community tab',
            style: LuxuryTextStyles.bodyMedium.copyWith(
              color: LuxuryColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    final partnerId = conversation['partnerId'] as String? ??
        (conversation['partner'] is Map<String, dynamic>
            ? (conversation['partner'] as Map<String, dynamic>)['id'] as String?
            : null) ??
        '';

    if (partnerId.isEmpty) return const SizedBox.shrink();

    final partnerName = conversation['partnerName'] as String? ??
        (conversation['partner'] is Map<String, dynamic>
            ? (conversation['partner'] as Map<String, dynamic>)['name'] as String?
            : null) ??
        conversation['partnerEmail'] as String? ??
        'Unknown';

    // Get profile picture URL from partner's profile
    final partnerProfile = conversation['partner'] is Map<String, dynamic>
        ? conversation['partner'] as Map<String, dynamic>
        : null;
    final profilePictureUrl = partnerProfile?['profile']?['profilePictureUrl'] as String?;
    final profilePicture = partnerProfile?['profile']?['profilePicture'] as String?;
    final displayPicture = profilePictureUrl ?? profilePicture;

    final lastMessageText = conversation['lastMessage'] as String? ??
        (conversation['lastMessage'] is Map<String, dynamic>
            ? (conversation['lastMessage'] as Map<String, dynamic>)['text']
                as String?
            : null) ??
        'No messages yet';

    final lastMessageTime = conversation['lastMessageTime'] as String? ??
        (conversation['lastMessage'] is Map<String, dynamic>
            ? (conversation['lastMessage'] as Map<String, dynamic>)['createdAt']
                as String?
            : null);

    final unreadCount = conversation['unreadCount'] as int? ?? 0;
    final isUnread = unreadCount > 0;

    return GoldCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      showGlow: isUnread,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              LuxuryPageRoute(
                page: ChatScreen(
                  partnerId: partnerId,
                  partnerName: partnerName,
                  partnerProfilePicture: displayPicture,
                ),
              ),
            ).then((_) => _loadConversations());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with notification badge
                Stack(
                  children: [
                    GoldAvatarFrame(
                      imageUrl: displayPicture,
                      initials: partnerName.split(' ').map((n) => n[0]).take(2).join(),
                      size: 56,
                      borderWidth: isUnread ? 2.5 : 2,
                      showGlow: isUnread,
                    ),
                    if (isUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: LuxuryColors.errorGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: LuxuryColors.mainBackground, width: 2),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: LuxuryTextStyles.bodySmall.copyWith(
                              color: LuxuryColors.mainBackground,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Message info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              partnerName,
                              style: LuxuryTextStyles.bodyLarge.copyWith(
                                fontSize: 18,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastMessageTime != null)
                            Text(
                              _formatTimestamp(lastMessageTime),
                              style: LuxuryTextStyles.bodySmall.copyWith(
                                color: isUnread
                                    ? LuxuryColors.primaryGold
                                    : LuxuryColors.subtleText,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessageText,
                              style: LuxuryTextStyles.bodyMedium.copyWith(
                                color: isUnread ? LuxuryColors.mutedText : LuxuryColors.subtleText,
                                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: isUnread ? LuxuryColors.primaryGold : LuxuryColors.subtleText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
