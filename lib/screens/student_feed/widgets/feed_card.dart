import 'package:flutter/material.dart';

class FeedCard extends StatelessWidget {
  final String name;
  final String avatarPath;
  final String content;

  const FeedCard({
    Key? key,
    required this.name,
    required this.avatarPath,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(avatarPath)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline, size: 20),
                SizedBox(width: 4),
                Text('Engagements'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
