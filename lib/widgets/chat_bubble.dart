// lib/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../utils/markdown_utils.dart';

class ChatBubble extends StatelessWidget {
  final String reply;
  const ChatBubble({required this.reply, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Strip out Markdown before rendering
    final plainText = stripMd(reply);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(plainText),
    );
  }
}
