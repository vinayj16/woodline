import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/models/message_model.dart';
import 'package:woodline/models/user_model.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/constants/app_constants.dart';
import 'package:woodline/utils/app_utils.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserImageUrl;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserImageUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String? _otherUserName;
  String? _otherUserImageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadOtherUserInfo();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOtherUserInfo() async {
    if (widget.otherUserName != null && widget.otherUserImageUrl != null) {
      setState(() {
        _otherUserName = widget.otherUserName;
        _otherUserImageUrl = widget.otherUserImageUrl;
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(widget.otherUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _otherUserName = userData?['displayName'] ?? 'Unknown User';
          _otherUserImageUrl = userData?['photoUrl'];
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Failed to load user info',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.user == null) return;

    final message = MessageModel(
      id: '', // Will be set by Firestore
      chatId: widget.chatId,
      senderId: userProvider.user!.id,
      receiverId: widget.otherUserId,
      content: messageText,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      // Add message to Firestore
      await _firestore
          .collection(AppConstants.messagesCollection)
          .add(message.toMap());

      // Update last message in chat
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .update({
            'lastMessage': messageText,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount': FieldValue.increment(1),
          });

      // Clear the message input
      _messageController.clear();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          message: 'Failed to send message',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view messages')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _otherUserImageUrl != null
                  ? NetworkImage(_otherUserImageUrl!)
                  : null,
              child: _otherUserImageUrl == null
                  ? Text(_otherUserName?.substring(0, 1) ?? '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Text(_otherUserName ?? 'Loading...'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show order/info dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(AppConstants.messagesCollection)
                  .where('chatId', isEqualTo: widget.chatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello!'),
                  );
                }

                // Mark messages as read
                _markMessagesAsRead(messages, currentUser.id);

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = MessageModel.fromFirestore(
                      messages[index] as DocumentSnapshot<Map<String, dynamic>>,
                    );
                    return _buildMessageBubble(message, currentUser);
                  },
                );
              },
            ),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Future<void> _markMessagesAsRead(
      List<QueryDocumentSnapshot<Object?>> messages, String currentUserId) async {
    final unreadMessages = messages
        .where((doc) =>
            (doc['receiverId'] == currentUserId) &&
            (doc['isRead'] == false))
        .toList();

    if (unreadMessages.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in unreadMessages) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  Widget _buildMessageBubble(MessageModel message, UserModel currentUser) {
    final isMe = message.senderId == currentUser.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && _otherUserImageUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(_otherUserImageUrl!),
                radius: 16,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : null,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
              child: Icon(
                message.isRead ? Icons.done_all : Icons.done,
                size: 16,
                color: message.isRead ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add attachment button
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // TODO: Add attachment functionality
              },
            ),
            // Message input field
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            // Send button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
