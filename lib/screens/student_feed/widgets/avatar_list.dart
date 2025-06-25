import 'package:flutter/material.dart';

class AvatarList extends StatelessWidget {
  final List<Map<String, String>> students;
  const AvatarList({Key? key, required this.students}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final s = students[i];
          return CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(s['avatar']!),
          );
        },
      ),
    );
  }
}
