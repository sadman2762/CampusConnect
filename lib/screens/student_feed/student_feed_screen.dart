// lib/screens/student_feed/student_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/student_profile_screen.dart';
import 'widgets/feed_card.dart';

class StudentFeedScreen extends StatefulWidget {
  static const routeName = '/student_feed';

  const StudentFeedScreen({Key? key}) : super(key: key);

  @override
  State<StudentFeedScreen> createState() => _StudentFeedScreenState();
}

class _StudentFeedScreenState extends State<StudentFeedScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _statusController = TextEditingController();
  bool _isEvent = false;

  CollectionReference<Map<String, dynamic>> get _feedCol =>
      FirebaseFirestore.instance.collection('feed');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _feedStream =>
      _feedCol.orderBy('timestamp', descending: true).snapshots();

  Future<void> _postStatus({bool isEvent = false}) async {
    final content = _statusController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users') // ✅ Must match where profile data is stored
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};
    final name = (data['name'] as String?)?.isNotEmpty == true
        ? data['name'] as String
        : (user.displayName ?? 'No Name');
    final avatar = (data['profilePic'] as String?)?.isNotEmpty == true
        ? data['profilePic'] as String
        : (user.photoURL ?? '');

    await _feedCol.add({
      'studentId': user.uid,
      'name': name,
      'avatar': avatar,
      'content': content,
      'timestamp': Timestamp.now(),
      'likes': {},
      'type': isEvent ? 'event' : 'normal', // ✅ THIS LINE IS MISSING
      'votes': isEvent ? {} : null, // 🟨 Initialize empty vote map
    });

    _statusController.clear();
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _showNearbyFriends() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * .5,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Expanded(
                      child: Center(child: Text('Nearby friends map…')),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Physical Meet Request'),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
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
                    backgroundImage:
                        AssetImage('assets/images/default_avatar.jpg'),
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
                final me = FirebaseAuth.instance.currentUser?.uid;
                if (me != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentProfileScreen(studentId: me),
                    ),
                  );
                } else {
                  Navigator.pushReplacementNamed(
                      context, ProfileScreen.routeName);
                }
              },
            ),
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
                onPressed: () => Navigator.pushReplacementNamed(
                    context, HomeScreen.routeName),
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined),
                onPressed: _showNearbyFriends,
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  final me = FirebaseAuth.instance.currentUser?.uid;
                  if (me != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentProfileScreen(studentId: me),
                      ),
                    );
                  } else {
                    Navigator.pushReplacementNamed(
                        context, ProfileScreen.routeName);
                  }
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
                  // Normal post
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () => _postStatus(isEvent: false),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  // Event post
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () => _postStatus(isEvent: true),
                    child: const Icon(Icons.event, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        return FeedCard(
                          postId: doc.id,
                          studentId: data['studentId'] as String,
                          name: data['name'] as String,
                          avatarPath: data['avatar'] as String,
                          content: data['content'] as String,
                          likes:
                              data['likes'] as Map<String, dynamic>?, // 👈 new
                          currentUserId:
                              FirebaseAuth.instance.currentUser!.uid, // 👈 new
                          type: data['type'] ?? 'normal',
                          votes: data['votes'] as Map<String, dynamic>?,
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
