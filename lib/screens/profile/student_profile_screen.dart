// lib/screens/profile/student_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StudentProfileScreen extends StatelessWidget {
  /// Named route for pushNamed navigation.
  static const routeName = '/student_profile';

  final String studentId;

  const StudentProfileScreen({Key? key, required this.studentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read the studentId passed via Navigator.pushNamed
    final args = ModalRoute.of(context)?.settings.arguments;
    final String? studentId = args is String ? args : null;

    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwnProfile =
        studentId == null || studentId == currentUser?.uid;

    if (isOwnProfile) {
      // Show the currently signed-in user’s Auth profile
      final name = currentUser?.displayName ?? 'No Name';
      final email = currentUser?.email ?? '';
      final avatarUrl = currentUser?.photoURL ?? '';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient header with avatar, name, email
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
                      backgroundImage: avatarUrl.startsWith('http')
                          ? NetworkImage(avatarUrl)
                          : avatarUrl.isNotEmpty
                              ? AssetImage(avatarUrl) as ImageProvider
                              : null,
                      child: avatarUrl.isEmpty
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
                    Text(
                      email,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              Text(
                "This is your account profile.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    // Otherwise, load another student's profile from Firestore
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
        future: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student profile not found"));
          }

          final data = snapshot.data!.data()!;
          final avatar = (data['avatar'] as String?) ?? '';
          final name = (data['name'] as String?) ?? 'Unknown';
          final email = (data['email'] as String?) ?? '';
          final location = (data['location'] as String?) ?? '';
          final title = (data['title'] as String?) ?? '';
          final institution = (data['institution'] as String?) ?? '';
          final projects = (data['projects']?.toString()) ?? '0';
          final followers = (data['followers']?.toString()) ?? '0';
          final reviews = (data['reviews']?.toString()) ?? '0';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient Header
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
                      Text(
                        email,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Job Title and Institution
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  institution,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 24),

                // Stats Row
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

                // Footer
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
