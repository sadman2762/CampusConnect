// lib/screens/student_feed/student_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/student_profile_screen.dart';
import 'widgets/avatar_list.dart';
import 'widgets/feed_card.dart';

class StudentFeedScreen extends StatefulWidget {
  static const routeName = '/student_feed';

  const StudentFeedScreen({Key? key}) : super(key: key);

  @override
  State<StudentFeedScreen> createState() => _StudentFeedScreenState();
}

class _StudentFeedScreenState extends State<StudentFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _statusController = TextEditingController();

  static const List<Map<String, String>> _students = [
    {
      'name': 'Piroska Peter',
      'avatar': 'assets/images/student1.jpg',
      'studentId': 'uid_001'
    },
    {
      'name': 'Anna Janos',
      'avatar': 'assets/images/student2.jpg',
      'studentId': 'uid_002'
    },
    {
      'name': 'Liu Wei',
      'avatar': 'assets/images/student3.jpg',
      'studentId': 'uid_003'
    },
    {
      'name': 'Sara Müller',
      'avatar': 'assets/images/student4.jpg',
      'studentId': 'uid_004'
    },
    {
      'name': 'Omar Ali',
      'avatar': 'assets/images/student5.jpg',
      'studentId': 'uid_005'
    },
    {
      'name': 'Noah Smith',
      'avatar': 'assets/images/student6.jpg',
      'studentId': 'uid_006'
    },
    {
      'name': 'Emma Brown',
      'avatar': 'assets/images/student7.jpg',
      'studentId': 'uid_007'
    },
  ];

  final List<Map<String, String>> _feed = [];

  void _postStatus() {
    if (_statusController.text.trim().isEmpty) return;
    setState(() {
      _feed.insert(0, {
        'studentId': 'uid_001',
        'name': 'Piroska Peter',
        'avatar': 'assets/images/student1.jpg',
        'content': _statusController.text.trim(),
      });
      _statusController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade100),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/student1.jpg'),
                  ),
                  SizedBox(width: 16),
                  Text('John Doe\njohndoe@example.com'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                    context, ProfileScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('My Inbox'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help Center'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                '© 2025 4TY',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Top Student Rankings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                        title: Text('Piroska Peter'), trailing: Text('9.8')),
                    ListTile(title: Text('Anna Janos'), trailing: Text('9.5')),
                    ListTile(title: Text('Liu Wei'), trailing: Text('9.2')),
                    ListTile(title: Text('Sara Müller'), trailing: Text('8.9')),
                    ListTile(title: Text('Omar Ali'), trailing: Text('8.7')),
                    ListTile(title: Text('Noah Smith'), trailing: Text('8.5')),
                    ListTile(title: Text('Emma Brown'), trailing: Text('8.2')),
                    ListTile(title: Text('John Doe'), trailing: Text('8.0')),
                    ListTile(title: Text('Jane Lee'), trailing: Text('7.8')),
                    ListTile(
                        title: Text('Max Mustermann'), trailing: Text('7.5')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomBottomNav.fab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                },
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined),
                onPressed: () => _showNearbyFriends(context),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, ProfileScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Student Feed',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _statusController,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _postStatus,
                    child: const Icon(Icons.send),
                  )
                ],
              ),
              const SizedBox(height: 16),
              AvatarList(students: _students),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _feed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final item = _feed[i];
                    return FeedCard(
                      name: item['name']!,
                      avatarPath: item['avatar']!,
                      content: item['content']!,
                      studentId: item['studentId']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNearbyFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: const [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/student2.jpg'),
                              ),
                              title: Text('Piroska Peter'),
                              subtitle: Text('200 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/student3.jpg'),
                              ),
                              title: Text('Anna Janos'),
                              subtitle: Text('350 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/student4.jpg'),
                              ),
                              title: Text('Liu Wei'),
                              subtitle: Text('480 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/student5.jpg'),
                              ),
                              title: Text('Sara Müller'),
                              subtitle: Text('520 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/student6.jpg'),
                              ),
                              title: Text('Omar Ali'),
                              subtitle: Text('610 m away'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Physical Meet Request'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var i = 5; i >= 1; i--)
                          Container(
                            width: i * 60.0,
                            height: i * 60.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50.withOpacity(i * 0.1),
                            ),
                          ),
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/images/student1.jpg'),
                        ),
                        const Positioned(
                          top: 40,
                          right: 80,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage('assets/images/student2.jpg'),
                          ),
                        ),
                        const Positioned(
                          bottom: 50,
                          left: 90,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage('assets/images/student3.jpg'),
                          ),
                        ),
                        const Positioned(
                          top: 100,
                          left: 40,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage('assets/images/student4.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
