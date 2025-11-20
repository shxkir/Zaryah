import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/neon_palette.dart';
import '../utils/initials_helper.dart';
import '../widgets/neon_background.dart';
import '../widgets/simple_avatar.dart';
import 'chat_screen.dart';
import 'user_profile_detail_screen.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<UserModel>? mentionedUsers;
  final List<Map<String, dynamic>>? housingListings;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.mentionedUsers,
    this.housingListings,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _apiService = ApiService();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m Zaryah AI, your educational assistant. Ask me about users, their skills, or anything else!',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text, {List<UserModel>? users, List<Map<String, dynamic>>? housingListings}) {
    setState(() {
      _messages.add(Message(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        mentionedUsers: users,
        housingListings: housingListings,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.sendChatMessage(message);

      // Check if this is a housing_results response
      if (response['type'] == 'housing_results' && response['listings'] != null) {
        final listings = (response['listings'] as List)
            .map((listing) => listing as Map<String, dynamic>)
            .toList();
        final responseText = response['message'] as String? ?? 'Found housing listings';
        _addBotMessage(responseText, housingListings: listings);
      } else {
        // Parse mentioned users if any
        List<UserModel>? mentionedUsers;
        if (response['mentionedUsers'] != null && (response['mentionedUsers'] as List).isNotEmpty) {
          mentionedUsers = (response['mentionedUsers'] as List)
              .map((user) => UserModel.fromJson(user))
              .toList();
        }

        final responseText = response['response'] as String? ?? 'No response from server';
        _addBotMessage(responseText, users: mentionedUsers);
      }
    } catch (e) {
      _addBotMessage('Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: NeonColors.blueCyanGradient,
                boxShadow: NeonShadows.glow(NeonColors.blue),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Zaryah AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Encrypted Learning Network',
                  style: TextStyle(
                    fontSize: 11,
                    color: NeonColors.mutedText,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: NeonColors.accentGradient,
              boxShadow: NeonShadows.glow(NeonColors.cyan),
            ),
          ),
        ),
      ),
      body: NeonBackground(
        child: Column(
          children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: const TextStyle(color: NeonColors.mutedText),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(
                        message: message,
                        onUserCardTap: (user) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileDetailScreen(user: user),
                            ),
                          );
                        },
                        onMessageTap: (user) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                partnerId: user.id,
                                partnerName: user.profile?.name ?? 'Unknown',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NeonColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: const TextStyle(
                      color: NeonColors.mutedText,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: NeonColors.background.withOpacity(0.9),
              border: Border(top: BorderSide(color: NeonColors.cyan.withOpacity(0.2))),
              boxShadow: [
                BoxShadow(
                  color: NeonColors.purple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: NeonColors.cyan.withOpacity(0.35)),
                        color: Colors.white.withOpacity(0.04),
                        boxShadow: [
                          BoxShadow(
                            color: NeonColors.blue.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: NeonColors.text),
                        decoration: const InputDecoration(
                          hintText: 'Ask about users, skills, learning...',
                          hintStyle: TextStyle(color: NeonColors.mutedText),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: NeonColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: NeonShadows.glow(NeonColors.cyan),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final Function(UserModel) onUserCardTap;
  final Function(UserModel) onMessageTap;
  final Function(Map<String, dynamic>)? onHousingTap;

  const _MessageBubble({
    required this.message,
    required this.onUserCardTap,
    required this.onMessageTap,
    this.onHousingTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleGradient = message.isUser
        ? NeonColors.blueCyanGradient
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x3320303C), Color(0x6610151F)],
          );
    final bubbleShadowColor = message.isUser ? NeonColors.cyan : NeonColors.purple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: NeonColors.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: NeonShadows.glow(NeonColors.purple),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: bubbleGradient,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: message.isUser
                          ? Colors.transparent
                          : NeonColors.purple.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bubbleShadowColor.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.black : NeonColors.text,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.black.withOpacity(0.6)
                              : NeonColors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeonColors.cyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.person, color: NeonColors.cyan, size: 20),
                ),
              ],
            ],
          ),

          // User cards if mentioned
          if (!message.isUser && message.mentionedUsers != null && message.mentionedUsers!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.person_pin, color: NeonColors.cyan, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Mentioned Users',
                          style: TextStyle(
                            color: NeonColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...message.mentionedUsers!.map((user) => _buildUserCard(user)),
                ],
              ),
            ),
          ],

          // Housing listings if available
          if (!message.isUser && message.housingListings != null && message.housingListings!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.home, color: NeonColors.cyan, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Available Properties',
                          style: TextStyle(
                            color: NeonColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...message.housingListings!.map((listing) => _buildHousingCard(listing, context)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final profile = user.profile;
    if (profile == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x2210151F), Color(0x110B0F16)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NeonColors.blue.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: NeonColors.blue.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: NeonColors.blueCyanGradient,
                boxShadow: NeonShadows.glow(NeonColors.blue),
              ),
              child: SimpleAvatar(
                size: 48,
                backgroundColor: NeonColors.background,
                child: Text(
                  initialsFromName(profile.name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NeonColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NeonColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.work_outline, size: 12, color: NeonColors.cyan),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.occupation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: NeonColors.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 12, color: NeonColors.purple),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.educationLevel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: NeonColors.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: NeonColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: NeonShadows.glow(NeonColors.cyan),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onUserCardTap(user),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, color: Colors.black, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    gradient: NeonColors.blueCyanGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: NeonShadows.glow(NeonColors.blue),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onMessageTap(user),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.message, color: Colors.black, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Message',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingCard(Map<String, dynamic> listing, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x2210151F), Color(0x110B0F16)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NeonColors.cyan.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: NeonColors.cyan.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Price
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing['title'] ?? 'Property',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: NeonColors.text,
                    ),
                  ),
                ),
                Text(
                  '₹${listing['monthlyPrice']?.toString() ?? '0'}/mo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeonColors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: NeonColors.purple),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    listing['locality'] ?? 'Unknown location',
                    style: const TextStyle(
                      fontSize: 13,
                      color: NeonColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Property details
            Row(
              children: [
                const Icon(Icons.bed, size: 14, color: NeonColors.cyan),
                const SizedBox(width: 4),
                Text(
                  '${listing['bedrooms'] ?? 0} BHK',
                  style: const TextStyle(
                    fontSize: 12,
                    color: NeonColors.text,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.bathtub, size: 14, color: NeonColors.cyan),
                const SizedBox(width: 4),
                Text(
                  '${listing['bathrooms'] ?? 0} Bath',
                  style: const TextStyle(
                    fontSize: 12,
                    color: NeonColors.text,
                  ),
                ),
                if (listing['squareFeet'] != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.square_foot, size: 14, color: NeonColors.cyan),
                  const SizedBox(width: 4),
                  Text(
                    '${listing['squareFeet']} sqft',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NeonColors.text,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // View button
            Container(
              decoration: BoxDecoration(
                gradient: NeonColors.blueCyanGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: NeonShadows.glow(NeonColors.cyan),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    // Navigate to housing screen
                    Navigator.pushNamed(context, '/housing');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: Colors.black, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'View on Map',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
