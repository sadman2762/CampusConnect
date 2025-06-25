// lib/screens/discussions/group_discussions_screen.dart

import 'package:flutter/material.dart';

class GroupDiscussionsScreen extends StatelessWidget {
  static const routeName = '/discussions';
  GroupDiscussionsScreen({Key? key}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _messages = [
    {
      'author': 'Torh',
      'avatar': 'assets/images/student1.jpg',
      'text':
          'Hey guys, I was going through web technologies, and I’m a bit confused about the difference between frontend and backend. Can someone explain?',
    },
    {
      'author': 'Sarah',
      'avatar': 'assets/images/student2.jpg',
      'text':
          'Sure! Frontend is what users see—HTML/CSS/JS. Backend is the server-side logic, databases, APIs, etc.',
    },
    {
      'author': 'Mark',
      'avatar': 'assets/images/student3.jpg',
      'text':
          'Think of it like a restaurant: frontend is the dining area, backend is the kitchen.',
    },
    {
      'author': 'Lisa',
      'avatar': 'assets/images/student4.jpg',
      'text':
          'Modern apps often use full-stack—one dev handles both with MERN, Django, etc.',
    },
  ];

  static const _myGroups = [
    'Flutter Devs',
    'Data Science Club',
    'Robotics Team',
    'Math Enthusiasts',
    'History Buffs',
    'AI Researchers',
    'UX Designers',
    'Mobile Ninjas',
    'Cybersecurity',
    'Game Dev Guild',
  ];

  static const _rankings = [
    {'name': 'Flutter Devs', 'score': '9.8'},
    {'name': 'AI Researchers', 'score': '9.5'},
    {'name': 'Data Science Club', 'score': '9.3'},
    {'name': 'Cybersecurity', 'score': '9.0'},
    {'name': 'Robotics Team', 'score': '8.7'},
    {'name': 'Game Dev Guild', 'score': '8.5'},
    {'name': 'UX Designers', 'score': '8.2'},
    {'name': 'Mobile Ninjas', 'score': '8.0'},
    {'name': 'Math Enthusiasts', 'score': '7.8'},
    {'name': 'History Buffs', 'score': '7.5'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildProfileDrawer(context),
      endDrawer: _buildGroupsDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Text(
                'Group Discussions',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Initiate or join discussions on various academic or campus-related topics to share insights and learn from others.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // remove `const` here so we can use a non-const fillColor
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for Discussions',
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

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'Generating Title…',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _messages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final m = _messages[i];
                            return _MessageBubble(
                              author: m['author']!,
                              avatarPath: m['avatar']!,
                              text: m['text']!,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Generate Summary'),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Start the discussion',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          elevation: 6,
          backgroundColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.group_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () => _showRankings(context),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDrawer(BuildContext c) => Drawer(
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
        _drawerTile(Icons.person_outline, 'My Profile'),
        _drawerTile(Icons.inbox_outlined, 'My Inbox'),
        _drawerTile(Icons.logout, 'Logout'),
        _drawerTile(Icons.help_outline, 'Help Center'),
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
  );

  Widget _buildGroupsDrawer(BuildContext c) => Drawer(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Groups',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // also make this non-const so fillColor can be dynamic
          TextField(
            decoration: InputDecoration(
              hintText: 'Search groups',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _myGroups.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.group),
                title: Text(_myGroups[i]),
                onTap: () => Navigator.pop(c),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showRankings(BuildContext c) {
    showModalBottomSheet(
      context: c,
      builder: (_) => SizedBox(
        height: 300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Top Group Rankings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _rankings.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) => ListTile(
                  title: Text(_rankings[i]['name']!),
                  trailing: Text(_rankings[i]['score']!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerTile(IconData icon, String label) =>
      ListTile(leading: Icon(icon), title: Text(label), onTap: () {});
}

/// A simple message bubble widget in `widgets/message_bubble.dart`
class _MessageBubble extends StatelessWidget {
  final String author, avatarPath, text;
  const _MessageBubble({
    required this.author,
    required this.avatarPath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundImage: AssetImage(avatarPath)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
