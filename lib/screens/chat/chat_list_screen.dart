import 'package:flutter/material.dart';
import 'package:woodline/theme/app_colors.dart';
import 'package:woodline/widgets/empty_state_widget.dart';
import 'package:woodline/widgets/app_button.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatItem> _mockChats = [
    ChatItem(
      id: '1',
      name: 'John Carpenter',
      lastMessage: 'Thanks for the custom table design!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
      avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
    ),
    ChatItem(
      id: '2',
      name: 'Sarah Woodworks',
      lastMessage: 'The bookshelf is ready for pickup',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      avatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
    ),
    ChatItem(
      id: '3',
      name: 'Mike\'s Furniture',
      lastMessage: 'Can we discuss the wood type?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      avatar: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search chats
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _mockChats.isEmpty
          ? EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Start chatting with woodworkers about your projects',
              action: AppButton(
                onPressed: () {
                  // TODO: Navigate to explore
                },
                text: 'Explore Products',
              ),
            )
          : ListView.builder(
              itemCount: _mockChats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(_mockChats[index]);
              },
            ),
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(chat.avatar),
        ),
        title: Text(
          chat.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          chat.lastMessage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(chat.timestamp),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'chatId': chat.id,
              'otherUserId': chat.id,
              'otherUserName': chat.name,
              'otherUserImageUrl': chat.avatar,
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}

class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String avatar;

  ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.avatar,
  });
}