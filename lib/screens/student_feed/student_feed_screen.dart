// lib/screens/student_feed/student_feed_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'widgets/avatar_list.dart';
import 'widgets/feed_card.dart';

class StudentFeedScreen extends StatelessWidget {
  static const routeName = '/student_feed';

  // Scaffold key to open drawers
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StudentFeedScreen({Key? key}) : super(key: key);

  // Dummy avatars strip
  static const List<Map<String, String>> _students = [
    {'name': 'Piroska Peter', 'avatar': 'assets/images/student1.jpg'},
    {'name': 'Anna Janos', 'avatar': 'assets/images/student2.jpg'},
    {'name': 'Liu Wei', 'avatar': 'assets/images/student3.jpg'},
    {'name': 'Sara Müller', 'avatar': 'assets/images/student4.jpg'},
    {'name': 'Omar Ali', 'avatar': 'assets/images/student5.jpg'},
    {'name': 'Noah Smith', 'avatar': 'assets/images/student6.jpg'},
    {'name': 'Emma Brown', 'avatar': 'assets/images/student7.jpg'},
  ];

  // Dummy feed posts
  static const List<Map<String, String>> _feed = [
    {
      'name': 'Piroska Peter',
      'avatar': 'assets/images/student1.jpg',
      'content':
          'Started learning Unity 3D, and wow—it’s a game-changer! 🔥 From debugging battles to the thrill of seeing my project come to life. Can’t wait for more! #Unity3D #GameDev #StudentLife',
    },
    {
      'name': 'Anna Janos',
      'avatar': 'assets/images/student2.jpg',
      'content':
          'Just presented my research on sustainable architecture. 🏛️ Feeling proud of the hard work paying off. Next stop: publication! #Architecture #Research',
    },
    {
      'name': 'Liu Wei',
      'avatar': 'assets/images/student3.jpg',
      'content':
          'Dug into data structures today—linked lists and trees are fascinating once you get the hang of them! 🌳 #DataStructures',
    },
    {
      'name': 'Sara Müller',
      'avatar': 'assets/images/student4.jpg',
      'content':
          'Practicing for my calculus exam. Integrals were tough at first, but practice makes perfect. 📐 #Calculus',
    },
    {
      'name': 'Omar Ali',
      'avatar': 'assets/images/student5.jpg',
      'content':
          'Group project meeting went great! Collaborating over Zoom with peers is a new experience. #Collaboration',
    },
    {
      'name': 'Noah Smith',
      'avatar': 'assets/images/student6.jpg',
      'content':
          'Finished my first Android app with Flutter. Hot reload is a lifesaver! 🚀 #Flutter',
    },
    {
      'name': 'Emma Brown',
      'avatar': 'assets/images/student7.jpg',
      'content':
          'Volunteered at the campus library today—met so many interesting people. 📚 #CampusLife',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // Left drawer (profile/inbox/logout/help)
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
              onTap: () => Navigator.pop(context),
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

      // Right drawer (rankings)
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
                      title: Text('Piroska Peter'),
                      trailing: Text('9.8'),
                    ),
                    ListTile(title: Text('Anna Janos'), trailing: Text('9.5')),
                    ListTile(title: Text('Liu Wei'), trailing: Text('9.2')),
                    ListTile(title: Text('Sara Müller'), trailing: Text('8.9')),
                    ListTile(title: Text('Omar Ali'), trailing: Text('8.7')),
                    ListTile(title: Text('Noah Smith'), trailing: Text('8.5')),
                    ListTile(title: Text('Emma Brown'), trailing: Text('8.2')),
                    ListTile(title: Text('John Doe'), trailing: Text('8.0')),
                    ListTile(title: Text('Jane Lee'), trailing: Text('7.8')),
                    ListTile(
                      title: Text('Max Mustermann'),
                      trailing: Text('7.5'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating 4TY and bottom nav
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
                onPressed: () => Navigator.pop(context),
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
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ],
          ),
        ),
      ),

      // Body
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Feed',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create and customize your personal profile, share academic posts and videos, '
                'and view your ranking based on contributions and reviews.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for Students',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
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

  /// Nearby friends bottom sheet
  void _showNearbyFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Row(
            children: [
              // Left: friends list + button
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
                                backgroundImage: AssetImage(
                                  'assets/images/student2.jpg',
                                ),
                              ),
                              title: Text('Piroska Peter'),
                              subtitle: Text('200 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/student3.jpg',
                                ),
                              ),
                              title: Text('Anna Janos'),
                              subtitle: Text('350 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/student4.jpg',
                                ),
                              ),
                              title: Text('Liu Wei'),
                              subtitle: Text('480 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/student5.jpg',
                                ),
                              ),
                              title: Text('Sara Müller'),
                              subtitle: Text('520 m away'),
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/student6.jpg',
                                ),
                              ),
                              title: Text('Omar Ali'),
                              subtitle: Text('610 m away'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: physical meet request
                        },
                        child: const Text('Physical Meet Request'),
                      ),
                    ],
                  ),
                ),
              ),

              // Right: concentric circles + user + small orbits
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 5 concentric rings
                        for (var i = 5; i >= 1; i--)
                          Container(
                            width: i * 60.0,
                            height: i * 60.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50.withOpacity(i * 0.1),
                            ),
                          ),

                        // user avatar center
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/images/student1.jpg',
                          ),
                        ),

                        // three small friend avatars in orbit
                        const Positioned(
                          top: 40,
                          right: 80,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/student2.jpg',
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 50,
                          left: 90,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/student3.jpg',
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 100,
                          left: 40,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/student4.jpg',
                            ),
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
