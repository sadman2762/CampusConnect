// lib/screens/discussions/group_discussions_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../profile/profile_screen.dart';
import 'summary_screen.dart';

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
  final _searchController = TextEditingController();

  User? get _me => FirebaseAuth.instance.currentUser;
  String get _myName => _me?.email?.split('@').first ?? 'You';

  CollectionReference<Map<String, dynamic>> get _messagesCol =>
      FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupName)
          .collection('messages');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _messagesStream =>
      _messagesCol.orderBy('timestamp').snapshots();

  Future<String> _getUserAvatar(String uid) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data()?['profilePic'] ?? 'assets/images/default.jpg';
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _me == null) return;
    final uid = _me!.uid;
    final avatarUrl = await _getUserAvatar(uid);
    await _messagesCol.add({
      'author': _myName,
      'avatar': avatarUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  Future<void> _generateSummary() async {
    final snapshot = await _messagesCol.orderBy('timestamp').get();
    final docs = snapshot.docs;
    final prompt = docs
        .map((d) => '${d.data()['author']}: ${d.data()['text']}')
        .join('\n');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(prompt: prompt),
      ),
    );
  }

  List<String> get _filteredGroups {
    final query = _searchController.text.toLowerCase();
    return _myGroups.where((g) => g.toLowerCase().contains(query)).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchRankings() async {
    List<Map<String, dynamic>> results = [];
    for (String group in _myGroups) {
      final snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(group)
          .collection('messages')
          .get();
      results.add({'name': group, 'score': snapshot.size});
    }
    results.sort((a, b) => b['score'].compareTo(a['score']));
    return results;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                        widget.groupName == 'Web Technologies'
                            ? 'General Chat'
                            : widget.groupName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _messagesStream,
                          builder: (ctx, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final messages = snap.data?.docs ?? [];
                            if (messages.isEmpty) {
                              return const Center(
                                  child: Text('No messages yet.'));
                            }
                            return ListView.separated(
                              itemCount: messages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final m = messages[i].data();
                                return _MessageBubble(
                                  author: m['author'] as String,
                                  avatarPath: m['avatar'] as String,
                                  text: m['text'] as String,
                                );
                              },
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
                  onPressed: _generateSummary,
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
                            horizontal: 12, vertical: 10),
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
                onPressed: () async {
                  final data = await _fetchRankings();
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Top Group Rankings',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: data.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 0),
                              itemBuilder: (_, i) => ListTile(
                                title: Text(
                                    data[i]['name'] == 'Web Technologies'
                                        ? 'General Chat'
                                        : data[i]['name']),
                                trailing: Text('${data[i]['score']}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.pushNamed(
                  context,
                  ProfileScreen.routeName,
                ),
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
                controller: _searchController,
                onChanged: (_) => setState(() {}),
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
                  itemCount: _filteredGroups.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(_filteredGroups[i] == 'Web Technologies'
                        ? 'General Chat'
                        : _filteredGroups[i]),
                    onTap: () {
                      Navigator.pop(c);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDiscussionsScreen(
                            groupName: _filteredGroups[i],
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

  static const _myGroups = [
    'Computer Aided Mathematics',
    'Discrete Mathematics',
    'Logic in Computer Science',
    'Introduction to Programming',
    'Calculus',
    'Data Structures and Algorithms',
    'Database Systems Lab',
    'Database Systems',
    'Operating Systems',
    'Network Architectures',
    'Applied Statistics',
    'Introduction to Computer Science',
    'High-Level Programming 1',
    'Web Technologies',
    'Applied Mathematics',
    'Foundations of Computer Security',
    'Foundations of AI',
    'High-Level Programming 2',
    'Web App Development',
    'Software Engineering',
    'Software Methodologies',
  ];
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
        CircleAvatar(
          backgroundImage: avatarPath.startsWith('http')
              ? NetworkImage(avatarPath)
              : AssetImage(avatarPath) as ImageProvider,
        ),
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
                Text(author,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
