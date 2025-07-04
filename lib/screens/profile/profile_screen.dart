// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/theme.dart';
import '../guidance/guidance_screen.dart';
import '../home/home_screen.dart';
import '../courses/courses_screen.dart'; // Add your courses screen route

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  Future<int> _getAcceptedConnectionCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('connections')
        .doc(userId)
        .collection('requests')
        .where('status', isEqualTo: 'accepted')
        .get();

    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final name = user.displayName ?? 'Your Name';
    final email = user.email ?? 'you@example.com';
    final photoUrl = user.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              HomeScreen.routeName,
            );
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? {};
          final bio = data['bio'] as String? ?? '';
          final university = data['university'] as String? ?? '';
          final year = data['year'] as String? ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
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
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
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

                // Buttons: Courses + Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              CoursesScreen.routeName,
                            );
                          },
                          icon: const Icon(Icons.menu_book),
                          label: const Text("Courses"),
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

                // Stats: Connections, Courses, Projects
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<int>(
                        future: _getAcceptedConnectionCount(user.uid),
                        builder: (context, connSnap) {
                          final value = connSnap.connectionState ==
                                  ConnectionState.waiting
                              ? '...'
                              : (connSnap.hasError
                                  ? '0'
                                  : connSnap.data.toString());

                          return _StatCard(label: "Connections", value: value);
                        },
                      ),
                      _StatCard(label: "Courses", value: "6"),
                      _StatCard(label: "Projects", value: "3"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Removed Skills & Experience section as requested
                // (the Padding with Skills and Experience has been deleted here)

                const SizedBox(height: 36),

                Text(
                  "© 2025 4TY",
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
