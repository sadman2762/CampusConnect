import 'package:flutter/material.dart';

class QueryCard extends StatelessWidget {
  final String author;
  final String title;
  final String text;
  final VoidCallback onAnswer;
  final VoidCallback onOthers;

  const QueryCard({
    Key? key,
    required this.author,
    required this.title,
    required this.text,
    required this.onAnswer,
    required this.onOthers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade200, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$author posted a query',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onAnswer,
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: const Text('Answer'),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: onOthers,
                icon: const Icon(Icons.group, size: 20),
                label: const Text('Others Answers'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
