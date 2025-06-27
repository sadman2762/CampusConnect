import 'package:flutter/material.dart';
import '../../profile/student_profile_screen.dart'; // Adjust path if needed

class AvatarList extends StatelessWidget {
  final List<Map<String, String>> students;

  const AvatarList({Key? key, required this.students}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final s = students[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudentProfileScreen(studentId: s['studentId']!),
                ),
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(s['avatar']!),
                ),
                const SizedBox(height: 4),
                Text(
                  s['name'] ?? '',
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
