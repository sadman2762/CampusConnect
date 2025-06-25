import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String name;
  final String avatarPath;
  final String lastMessage;
  final String time;
  final VoidCallback? onTap;

  const ChatItem({
    Key? key,
    required this.name,
    required this.avatarPath,
    required this.lastMessage,
    required this.time,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage(avatarPath),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }
}
