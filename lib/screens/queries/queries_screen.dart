import 'package:flutter/material.dart';
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
  int _viewMy = 0; // 0 = all queries, 1 = my queries
  final _newQueryController = TextEditingController();

  static const _allQueries = [
    {
      'author': 'Rita',
      'title': 'Understanding DBMS Normalization',
      'text':
          'Can someone explain normalization in simple terms? I’m confused about how to identify functional dependencies and apply normalization steps?',
    },
    {
      'author': 'Mark',
      'title': 'Final Year Project Topics',
      'text':
          'I’m looking for innovative project ideas for my final year. Should I go for AI-based projects, web applications, or something else? Any suggestions?',
    },
    {
      'author': 'Alex Chen',
      'title': 'Tips for Effective Note-Taking',
      'text':
          'What are your best strategies for taking lecture notes that actually help with revision later?',
    },
    {
      'author': 'John Doe',
      'title': 'Time Management Hacks',
      'text':
          'How do you balance assignments, part-time work, and social life without burning out?',
    },
    {
      'author': 'Maya Patel',
      'title': 'Best Study Apps?',
      'text':
          'Can anyone recommend mobile apps that help track study time and improve focus?',
    },
  ];

  static const _myQueries = [
    {'author': 'You', 'title': 'Understanding DBMS Normalization', 'text': '…'},
    {'author': 'You', 'title': 'Time Management Hacks', 'text': '…'},
    {'author': 'You', 'title': 'Best Study Apps?', 'text': '…'},
  ];

  static const _topQueries = [
    {'title': 'Understanding DBMS Normalization', 'engagements': '125'},
    {'title': 'Final Year Project Topics', 'engagements': '98'},
    {'title': 'Tips for Effective Note-Taking', 'engagements': '76'},
    {'title': 'Time Management Hacks', 'engagements': '54'},
    {'title': 'Best Study Apps?', 'engagements': '32'},
  ];

  @override
  void dispose() {
    _newQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final displayList = _viewMy == 0 ? _allQueries : _myQueries;

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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: () {
                      final text = _newQueryController.text.trim();
                      if (text.isNotEmpty) {
                        // TODO: handle posting the new query
                        _newQueryController.clear();
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: displayList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final q = displayList[i];
                  return QueryCard(
                    author: q['author']!,
                    title: q['title']!,
                    text: q['text']!,
                    onAnswer: () {
                      // TODO: handle Answer
                    },
                    onOthers: () {
                      // TODO: handle Others Answers
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
        onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
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
                child: ListView.separated(
                  itemCount: _topQueries.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final t = _topQueries[i];
                    return ListTile(
                      title: Text(t['title']!),
                      trailing: Text('${t['engagements']} 👍'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
