import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../courses/courses_screen.dart';
import '../student_feed/student_feed_screen.dart';
import '../discussions/group_discussions_screen.dart';
import '../guidance/guidance_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../help/help_center_screen.dart';

import 'widgets/query_card.dart';

class QueriesScreen extends StatefulWidget {
  static const routeName = '/queries';
  const QueriesScreen({Key? key}) : super(key: key);

  @override
  State<QueriesScreen> createState() => _QueriesScreenState();
}

class _QueriesScreenState extends State<QueriesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _newQueryController = TextEditingController();
  int _viewMy = 0; // 0 = all queries, 1 = my queries

  User? get _me => FirebaseAuth.instance.currentUser;
  String get _myUid => _me?.uid ?? '';
  String get _myName => _me?.email?.split('@').first ?? 'Anonymous';

  @override
  void dispose() {
    _newQueryController.dispose();
    super.dispose();
  }

  /// Stream of either all queries or just mine
  Stream<QuerySnapshot<Map<String, dynamic>>> get _queryStream {
    final col = FirebaseFirestore.instance
        .collection('queries')
        .orderBy('timestamp', descending: true);
    return _viewMy == 1
        ? col.where('uid', isEqualTo: _myUid).snapshots()
        : col.snapshots();
  }

  /// Post new query (now includes initial likes = 0)
  Future<void> _postNewQuery() async {
    final text = _newQueryController.text.trim();
    if (text.isEmpty || _me == null) return;
    await FirebaseFirestore.instance.collection('queries').add({
      'author': _myName,
      'title': text,
      'text': text,
      'uid': _myUid,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _newQueryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildTopQueriesDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Queries Section',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Post-a-query input bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _newQueryController,
                decoration: InputDecoration(
                  hintText: 'Post your question...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _postNewQuery,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _postNewQuery(),
              ),
            ),

            const SizedBox(height: 16),
            // Toggle All vs. My
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('All Queries'),
                  selected: _viewMy == 0,
                  onSelected: (_) => setState(() => _viewMy = 0),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('My Queries'),
                  selected: _viewMy == 1,
                  onSelected: (_) => setState(() => _viewMy = 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live list
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _queryStream,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No queries yet.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      final data = doc.data();
                      return QueryCard(
                        queryId: doc.id,
                        author: data['author'] as String,
                        title: data['title'] as String,
                        text: data['text'] as String,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: Colors.white,
        child: const Text(
          '4TY',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, AIChatScreen.routeName),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.list_alt,
                  color: _viewMy == 1 ? theme.primaryColor : Colors.black54,
                ),
                onPressed: () => setState(() => _viewMy = 1),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.bar_chart_outlined),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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

  Drawer _buildTopQueriesDrawer() => Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Queries',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('queries')
                      .orderBy('likes', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final topDocs = snap.data?.docs ?? [];
                    if (topDocs.isEmpty) {
                      return const Center(child: Text('No queries yet.'));
                    }
                    return ListView.separated(
                      itemCount: topDocs.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final data = topDocs[i].data();
                        final likes = data['likes'] as int? ?? 0;
                        return ListTile(
                          leading: Text('${i + 1}.'),
                          title: Text(data['title'] as String),
                          trailing: Text('$likes 👍'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
