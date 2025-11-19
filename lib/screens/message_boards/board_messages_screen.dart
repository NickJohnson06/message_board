import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:message_board/models/app_user.dart';
import 'package:message_board/models/message.dart';
import 'package:message_board/models/message_board.dart';
import 'package:message_board/services/auth_service.dart';

class BoardMessagesScreen extends StatefulWidget {
  final MessageBoard board;

  const BoardMessagesScreen({
    super.key,
    required this.board,
  });

  @override
  State<BoardMessagesScreen> createState() => _BoardMessagesScreenState();
}

class _BoardMessagesScreenState extends State<BoardMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  AppUser? _currentUser;
  bool _sending = false;

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board.id)
          .collection('messages');

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.instance.getCurrentAppUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    setState(() {
      _sending = true;
    });

    try {
      await _messagesRef.add({
        'text': text,
        'userId': _currentUser!.uid,
        'displayName': _currentUser!.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Widget _buildMessageTile(Message message) {
    final isMine = message.userId == AuthService.instance.currentUser?.uid;
    final timeText = message.createdAt != null
        ? TimeOfDay.fromDateTime(message.createdAt!).format(context)
        : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomLeft: isMine ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMine ? Radius.zero : const Radius.circular(12),
          ),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messagesRef
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load messages.'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.\nBe the first to say something!',
              textAlign: TextAlign.center,
            ),
          );
        }

        final messages = docs.map((d) => Message.fromDoc(d)).toList();

        return ListView.builder(
          reverse: true, // newest at bottom visually
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageTile(message);
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    final canSend = _messageController.text.trim().isNotEmpty &&
        _currentUser != null &&
        !_sending;

    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canSend ? _sendMessage : null,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _currentUser == null
        ? 'Loading user...'
        : 'Signed in as ${_currentUser!.displayName}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.board.name),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputBar(),
        ],
      ),
    );
  }
}