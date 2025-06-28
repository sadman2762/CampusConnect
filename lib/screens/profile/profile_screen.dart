// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/theme.dart';
import '../guidance/guidance_screen.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

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
          // Firestore loading / error
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
                // Gradient Header with avatar, name & email
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

                // Connect & Message buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Connect logic
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

                // Stats Row: Friends, Rank, Comments
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StatCard(label: "Friends", value: "65"),
                      _StatCard(label: "Rank", value: "12"),
                      _StatCard(label: "Comments", value: "21"),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Footer
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
