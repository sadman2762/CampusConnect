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

  // Firestore collection for feed posts
  CollectionReference<Map<String, dynamic>> get _feedCol =>
      FirebaseFirestore.instance.collection('feed');

  // Live stream of posts ordered by newest first
  Stream<QuerySnapshot<Map<String, dynamic>>> get _feedStream =>
      _feedCol.orderBy('timestamp', descending: true).snapshots();

  /// Post a new status to Firestore
  Future<void> _postStatus() async {
    final content = _statusController.text.trim();
    if (content.isEmpty) return;

    // Hardcode as Piroska Peter for now
    await _feedCol.add({
      'studentId': 'uid_001',
      'name': 'Piroska Peter',
      'avatar': 'assets/images/student1.jpg',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _statusController.clear();
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
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
                            // ...
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
              // map view omitted for brevity
              Expanded(child: Container()),
            ],
          ),
        );
      },
    );
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
            // ...
          ],
        ),
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Top Student Rankings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),
              // ...
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
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
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
              // Firestore-backed feed list
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _feedStream,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No posts yet.'));
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        return FeedCard(
                          postId: doc.id,
                          name: data['name'] as String,
                          studentId: data['studentId'] as String,
                          avatarPath: data['avatar'] as String,
                          content: data['content'] as String,
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
    );
  }
}
