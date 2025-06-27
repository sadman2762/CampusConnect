// lib/screens/discussions/group_discussions_screen.dart

import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'summary_screen.dart'; // <-- Required for navigation

class GroupDiscussionsScreen extends StatefulWidget {
  final String groupName;

  const GroupDiscussionsScreen({Key? key, required this.groupName})
      : super(key: key);

  static const routeName = '/discussions';

  @override
  State<GroupDiscussionsScreen> createState() => _GroupDiscussionsScreenState();
}

class _GroupDiscussionsScreenState extends State<GroupDiscussionsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();

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

  final Map<String, List<Map<String, String>>> _messagesPerGroup = {
    'Flutter Devs': [],
    'Data Science Club': [],
    'Robotics Team': [],
    'Math Enthusiasts': [],
    'History Buffs': [],
    'AI Researchers': [],
    'UX Designers': [],
    'Mobile Ninjas': [],
    'Cybersecurity': [],
    'Game Dev Guild': [],
    'CS23 Webtech': [
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
    ],
  };

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messagesPerGroup[widget.groupName] ??= [];
      _messagesPerGroup[widget.groupName]!.add({
        'author': 'You',
        'avatar': 'assets/images/student1.jpg',
        'text': text,
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final messages = _messagesPerGroup[widget.groupName] ?? [];

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildGroupsDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
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
                        widget.groupName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: messages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final m = messages[i];
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
                  onPressed: () {
                    final groupMessages =
                        _messagesPerGroup[widget.groupName] ?? [];
                    final prompt = groupMessages
                        .map((m) => '${m["author"]}: ${m["text"]}')
                        .join('\n');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SummaryScreen(prompt: prompt),
                      ),
                    );
                  },
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
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
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
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
        child: const Text(
          '4TY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
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
                onPressed: () =>
                    Navigator.pushNamed(context, ProfileScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    onTap: () {
                      Navigator.pop(c);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDiscussionsScreen(
                            groupName: _myGroups[i],
                          ),
                        ),
                      );
                    },
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
}

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
