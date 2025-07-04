// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import '../courses/courses_screen.dart';
import '../student_feed/student_feed_screen.dart';
import '../discussions/group_discussions_screen.dart';
import '../queries/queries_screen.dart';
import '../guidance/guidance_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../help/help_center_screen.dart';

// Widgets
import 'widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Map<String, String>> _features = [
    {
      'title': 'Courses',
      'subtitle':
          'Explore our comprehensive course materials, exam patterns, and more.',
      'image': 'assets/images/courses.jpg',
    },
    {
      'title': 'Student Feed',
      'subtitle': 'Customize your profile and contribute to our community.',
      'image': 'assets/images/profiles.jpg',
    },
    {
      'title': 'Group Discussions',
      'subtitle': 'Join discussions on various topics and share your insights.',
      'image': 'assets/images/discussions.jpg',
    },
    {
      'title': 'One-to-one Guidance',
      'subtitle': 'Request personalized academic support from peers.',
      'image': 'assets/images/guidance.jpg',
    },
    {
      'title': 'Queries Section',
      'subtitle': 'Post questions and receive answers from the community.',
      'image': 'assets/images/queries.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.purple.shade50,
      drawer: _buildSideDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.account_circle_outlined, size: 28),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'CampusConnect',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),

                  // 🔔 Notification Bell with badge
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('items')
                        .where('seen', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final hasUnseen = snapshot.data?.docs.isNotEmpty ?? false;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          ),
                          if (hasUnseen)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                color: Colors.purple.shade50,
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _features.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final f = _features[i];
                    return FeatureCard(
                      title: f['title']!,
                      subtitle: f['subtitle']!,
                      imagePath: f['image']!,
                      onTap: () {
                        switch (f['title']) {
                          case 'Courses':
                            Navigator.pushNamed(
                                context, CoursesScreen.routeName);
                            break;
                          case 'Student Feed':
                            Navigator.pushNamed(
                                context, StudentFeedScreen.routeName);
                            break;
                          case 'Group Discussions':
                            Navigator.pushNamed(
                                context, GroupDiscussionsScreen.routeName);
                            break;
                          case 'One-to-one Guidance':
                            Navigator.pushNamed(
                                context, GuidanceScreen.routeName);
                            break;
                          case 'Queries Section':
                            Navigator.pushNamed(
                                context, QueriesScreen.routeName);
                            break;
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          elevation: 6,
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () => Navigator.pushNamed(context, AIChatScreen.routeName),
          child: const Text(
            '4TY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade100),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/images/profiles.jpg')
                          as ImageProvider,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SECTION 1
          _drawerRowItem(Icons.person_outline, 'My Profile', () {
            Navigator.pushNamed(context, ProfileScreen.routeName);
          }),
          const Divider(),

          // SECTION 2 — Custom Navigation
          _drawerRowItem(Icons.chat_bubble_outline, 'My Inbox', () {
            Navigator.pushNamed(context, GuidanceScreen.routeName);
          }),
          _drawerRowItem(Icons.group_outlined, 'My Group', () {
            Navigator.pushNamed(
              context,
              GroupDiscussionsScreen.routeName,
            );
          }),
          _drawerRowItem(Icons.menu_book_outlined, 'My Courses', () {
            Navigator.pushNamed(
              context,
              CoursesScreen.routeName,
            );
          }),
          _drawerRowItem(Icons.question_answer_outlined, 'My Queries', () {
            Navigator.pushNamed(
              context,
              QueriesScreen.routeName,
            );
          }),
          _drawerRowItem(Icons.settings_outlined, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => const SettingsScreen(),
              ),
            );
          }),
          const Divider(),

          // SECTION 3
          _drawerRowItem(Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }),
          _drawerRowItem(Icons.help_outline, '4TY Help Center', () {
            Navigator.pushNamed(context, HelpCenterScreen.routeName);
          }),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              '© 2025 4TY',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerRowItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
