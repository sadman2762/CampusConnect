// lib/screens/guidance/guidance_screen.dart

import 'package:flutter/material.dart';

class GuidanceScreen extends StatefulWidget {
  static const routeName = '/guidance';
  const GuidanceScreen({Key? key}) : super(key: key);

  @override
  _GuidanceScreenState createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  // 8 chat peers
  static const _chatPeers = [
    {
      'name': 'Alice Nguyen',
      'avatar': 'assets/images/student1.jpg',
      'last': 'Sure—happy to help!',
      'time': '09:45',
    },
    {
      'name': 'Bruno Silva',
      'avatar': 'assets/images/student2.jpg',
      'last': 'Let’s schedule a call.',
      'time': '08:30',
    },
    {
      'name': 'Chloe Zhang',
      'avatar': 'assets/images/student3.jpg',
      'last': 'Notes uploaded.',
      'time': 'Yesterday',
    },
    {
      'name': 'Daniel Kim',
      'avatar': 'assets/images/student4.jpg',
      'last': 'Review my draft?',
      'time': 'Tue',
    },
    {
      'name': 'Emma García',
      'avatar': 'assets/images/student5.jpg',
      'last': 'Walkthrough ready!',
      'time': 'Mon',
    },
    {
      'name': 'Fiona Li',
      'avatar': 'assets/images/student6.jpg',
      'last': 'Can explain that.',
      'time': 'Sun',
    },
    {
      'name': 'George Park',
      'avatar': 'assets/images/student7.jpg',
      'last': 'Zoom call?',
      'time': 'Sat',
    },
    {
      'name': 'Hannah Schultz',
      'avatar': 'assets/images/student8.jpg',
      'last': 'Sent slides.',
      'time': 'Fri',
    },
  ];

  // 8 guidance requests
  static const _requests = [
    {
      'name': 'Ibrahim Khan',
      'avatar': 'assets/images/student9.jpg',
      'request': 'Help with stats?',
    },
    {
      'name': 'Julia Roberts',
      'avatar': 'assets/images/student10.jpg',
      'request': 'Proofread essay?',
    },
    {
      'name': 'Kira Yamamoto',
      'avatar': 'assets/images/student11.jpg',
      'request': 'Need chem tutor.',
    },
    {
      'name': 'Leo Smith',
      'avatar': 'assets/images/student12.jpg',
      'request': 'Project guidance.',
    },
    {
      'name': 'Mia Lopez',
      'avatar': 'assets/images/student13.jpg',
      'request': 'Calculus help.',
    },
    {
      'name': 'Nina Patel',
      'avatar': 'assets/images/student14.jpg',
      'request': 'Debug my code.',
    },
    {
      'name': 'Oscar Müller',
      'avatar': 'assets/images/student15.jpg',
      'request': 'Time management tips?',
    },
    {
      'name': 'Priya Singh',
      'avatar': 'assets/images/student16.jpg',
      'request': 'Lecture notes please.',
    },
  ];

  // Top-peer rankings
  static const _peerRankings = [
    {'name': 'Alice Nguyen', 'score': '9.8'},
    {'name': 'Emma García', 'score': '9.5'},
    {'name': 'Bruno Silva', 'score': '9.3'},
    {'name': 'Chloe Zhang', 'score': '9.0'},
    {'name': 'Daniel Kim', 'score': '8.7'},
    {'name': 'Fiona Li', 'score': '8.5'},
    {'name': 'George Park', 'score': '8.2'},
    {'name': 'Hannah Schultz', 'score': '8.0'},
    {'name': 'Ibrahim Khan', 'score': '7.8'},
    {'name': 'Julia Roberts', 'score': '7.5'},
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // Left drawer: Profile menu
      drawer: _buildProfileDrawer(),

      // Right drawer: Top peer rankings
      endDrawer: _buildRankingDrawer(),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text(
                'One-to-One Guidance',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Request personalized academic support from peers.',
                style: textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for peer',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TabBar: Chats / Requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Chats'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Chat list
                  ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _chatPeers.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final p = _chatPeers[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(p['avatar']!),
                        ),
                        title: Text(p['name']!),
                        subtitle: Text(p['last']!),
                        trailing: Text(
                          p['time']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {},
                      );
                    },
                  ),

                  // Request list
                  ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _requests.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final r = _requests[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(r['avatar']!),
                        ),
                        title: Text(r['name']!),
                        subtitle: Text(r['request']!),
                        onTap: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 4TY FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 4-icon footer nav
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pop(context),
              ),

              // Chats tab
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                color: _tabController.index == 0 ? theme.primaryColor : null,
                onPressed: () => setState(() => _tabController.index = 0),
              ),

              const SizedBox(width: 48), // FAB gap
              // Requests tab
              IconButton(
                icon: const Icon(Icons.how_to_reg_outlined),
                color: _tabController.index == 1 ? theme.primaryColor : null,
                onPressed: () => setState(() => _tabController.index = 1),
              ),

              // Rankings drawer
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------
  // Drawers
  // --------------------

  Widget _buildProfileDrawer() => Drawer(
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

  Widget _buildRankingDrawer() => Drawer(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Peers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _peerRankings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final pr = _peerRankings[i];
                return ListTile(
                  title: Text(pr['name']!),
                  trailing: Text(pr['score']!),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  ListTile _drawerTile(IconData icon, String label) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: () => Navigator.pop(context),
  );
}
