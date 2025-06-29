import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../guidance/guidance_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  static const routeName = '/student_profile';

  final String studentId;

  const StudentProfileScreen({Key? key, required this.studentId})
      : super(key: key);

  String _ordinalSuffix(String y) {
    switch (y) {
      case '1':
        return 'st';
      case '2':
        return 'nd';
      case '3':
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _sendConnectionRequest(String targetId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final connectionRef = FirebaseFirestore.instance
        .collection('connections')
        .doc(targetId)
        .collection('requests')
        .doc(currentUser.uid);

    await connectionRef.set({
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwnProfile = studentId == currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(studentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student profile not found"));
          }

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? 'Unknown';
          final email = data['email'] ?? '';
          final avatar = data['profilePic'] ?? '';
          final bio = data['bio'] ?? '';
          final university = data['university'] ?? '';
          final year = data['year'] ?? '';

          final projects = (data['projects']?.toString()) ?? '0';
          final followers = (data['followers']?.toString()) ?? '0';
          final reviews = (data['reviews']?.toString()) ?? '0';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: avatar.startsWith('http')
                            ? NetworkImage(avatar)
                            : avatar.isNotEmpty
                                ? AssetImage(avatar) as ImageProvider
                                : null,
                        child: avatar.isEmpty
                            ? const Icon(Icons.person_outline, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bio
                if (bio.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // University & Year
                if (university.isNotEmpty || year.isNotEmpty) ...[
                  Text(
                    university,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (year.isNotEmpty)
                    Text(
                      '$year${_ordinalSuffix(year)} year',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 24),
                ],

                // Connect & Message buttons
                if (!isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _sendConnectionRequest(studentId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Connection request sent!"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text("Connect"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                GuidanceScreen.routeName,
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text("Private Message"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatCard(label: "Projects", value: projects),
                      _StatCard(label: "Followers", value: followers),
                      _StatCard(label: "Reviews", value: reviews),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  "© 2025 4TY - all rights reserved",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
