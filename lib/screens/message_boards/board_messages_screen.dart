import 'package:flutter/material.dart';
import 'package:message_board/models/message_board.dart';

class BoardMessagesScreen extends StatelessWidget {
  final MessageBoard board;

  const BoardMessagesScreen({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(board.name),
      ),
      body: Center(
        child: Text(
          'Messages for "${board.name}" will go here.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}