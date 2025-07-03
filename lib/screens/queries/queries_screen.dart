import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ai_chat/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
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
  int _viewMy = 0;
  String _searchKeyword = '';

  User? get _me => FirebaseAuth.instance.currentUser;
  String get _myUid => _me?.uid ?? '';
  String get _myName => _me?.email?.split('@').first ?? 'Anonymous';

  @override
  void dispose() {
    _newQueryController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _queryStream {
    final col = FirebaseFirestore.instance
        .collection('queries')
        .orderBy('timestamp', descending: true);

    if (_viewMy == 1) {
      if (_myUid.isEmpty) return const Stream.empty();
      return col.where('uid', isEqualTo: _myUid).snapshots();
    } else {
      return col.snapshots();
    }
  }

  Future<void> _postNewQuery() async {
    final text = _newQueryController.text.trim();
    if (text.isEmpty || _myUid.isEmpty) return;

    await FirebaseFirestore.instance.collection('queries').add({
      'author': _myName,
      'title': text,
      'uid': _myUid,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _newQueryController.clear();
  }

  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final _searchController = TextEditingController();

        return AlertDialog(
          title: const Text('Search Queries'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Enter keyword...'),
            onSubmitted: (keyword) {
              Navigator.pop(context);
              _filterQueries(keyword);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _filterQueries(_searchController.text.trim());
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _filterQueries(String keyword) {
    setState(() {
      _searchKeyword = keyword.toLowerCase();
    });
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
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _newQueryController,
                decoration: InputDecoration(
                  hintText: 'Post your question...',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _openSearchDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_outlined),
                        onPressed: _postNewQuery,
                      ),
                    ],
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
            if (_viewMy == 1 && _myUid.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Please log in to view your queries.'),
                ),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _queryStream,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allDocs = snap.data?.docs ?? [];

                    final docs = _searchKeyword.isEmpty
                        ? allDocs
                        : allDocs.where((doc) {
                            final title =
                                (doc['title'] ?? '').toString().toLowerCase();
                            return title.contains(_searchKeyword);
                          }).toList();

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
// 🔄 Fetch user profile for each query (to show profilePic and author name)
                        final authorId =
                            data['uid']; // must be stored when query is posted

                        return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(authorId)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink(); // or show loading
                            }

                            final userData = snapshot.data!.data();
                            final profilePic = userData?['profilePic'] ??
                                'https://example.com/default.jpg'; // fallback

                            return QueryCard(
                              queryId: doc.id,
                              author: userData?['name'] ??
                                  data['author'] ??
                                  'Unknown',
                              title: data['title'] ?? '',
                              text: '',
                              profilePicUrl: profilePic,
                            );
                          },
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
                          title: Text(data['title'] ?? ''),
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
