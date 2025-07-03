import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String author;
  final String avatarPath;
  final String text;
  final Map<String, dynamic>? reactions;

  const MessageBubble({
    Key? key,
    required this.author,
    required this.avatarPath,
    required this.text,
    this.reactions,
  }) : super(key: key);

  Widget buildReactions(Map<String, dynamic>? reactionsMap) {
    if (reactionsMap == null || reactionsMap.isEmpty) return SizedBox();

    final emojiCount = <String, int>{};
    reactionsMap.values.forEach((emoji) {
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    });

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: emojiCount.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${entry.key} ${entry.value}'),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarPath.startsWith('http')
              ? NetworkImage(avatarPath)
              : AssetImage(avatarPath) as ImageProvider,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(text),
                buildReactions(reactions), // ✅ Emoji reactions bubble
              ],
            ),
          ),
        ),
      ],
    );
  }
}
