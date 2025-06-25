import 'package:flutter/material.dart';

class UpdateItem extends StatelessWidget {
  final String text;

  const UpdateItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/profiles.jpg'),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text('Posted just now', style: TextStyle(fontSize: 12)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
