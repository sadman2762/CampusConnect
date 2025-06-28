// lib/screens/student_feed/widgets/avatar_list.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/student_profile_screen.dart';

class AvatarList extends StatelessWidget {
  /// Maximum number of other students to display
  final int limit;

  const AvatarList({Key? key, this.limit = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser?.uid;

    return SizedBox(
      height: 80,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .orderBy('name')
            .limit(limit + (me != null ? 1 : 0))
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          // Exclude current user
          final others = docs.where((d) => d.id != me).take(limit).toList();
          if (others.isEmpty) {
            return const Center(child: Text('No other students.'));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: others.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final doc = others[i];
              final data = doc.data();
              final avatar = (data['avatar'] as String?) ?? '';
              final name = (data['name'] as String?) ?? '';
              final sid = doc.id;

              ImageProvider imageProvider;
              if (avatar.startsWith('http')) {
                imageProvider = NetworkImage(avatar);
              } else if (avatar.isNotEmpty) {
                imageProvider = AssetImage(avatar);
              } else {
                imageProvider =
                    const AssetImage('assets/images/default_avatar.jpg');
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    StudentProfileScreen.routeName,
                    arguments: sid,
                  );
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: imageProvider,
                      child: avatar.isEmpty
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 56, // constrain text width
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
