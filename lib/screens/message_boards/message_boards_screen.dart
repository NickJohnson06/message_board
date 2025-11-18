import 'package:flutter/material.dart';
import 'package:message_board/models/message_board.dart';
import 'board_messages_screen.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  List<MessageBoard> _buildBoards() {
    return const [
      MessageBoard(
        id: 'general',
        name: 'General Discussion',
        icon: Icons.forum_outlined,
        order: 1,
      ),
      MessageBoard(
        id: 'announcements',
        name: 'Announcements',
        icon: Icons.campaign_outlined,
        order: 0,
      ),
      MessageBoard(
        id: 'help',
        name: 'Help & Support',
        icon: Icons.help_outline,
        order: 2,
      ),
      MessageBoard(
        id: 'random',
        name: 'Random',
        icon: Icons.bubble_chart_outlined,
        order: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final boards = _buildBoards()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: boards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final board = boards[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(board.icon),
            ),
            title: Text(
              board.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Board ID: ${board.id}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoardMessagesScreen(board: board),
                ),
              );
            },
          ),
        );
      },
    );
  }
}