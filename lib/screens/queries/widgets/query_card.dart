import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryCard extends StatefulWidget {
  final String queryId;
  final String author;
  final String title;
  final String text;

  const QueryCard({
    Key? key,
    required this.queryId,
    required this.author,
    required this.title,
    required this.text,
  }) : super(key: key);

  @override
  State<QueryCard> createState() => _QueryCardState();
}

class _QueryCardState extends State<QueryCard> {
  final _answerController = TextEditingController();
  bool _showAnswers = false;

  User? get _me => FirebaseAuth.instance.currentUser;
  String get _myName => _me?.email?.split('@').first ?? 'Anonymous';

  /// Increment likes
  Future<void> _toggleLike(int currentLikes) async {
    await FirebaseFirestore.instance
        .collection('queries')
        .doc(widget.queryId)
        .update({'likes': currentLikes + 1});
  }

  /// Post an answer
  Future<void> _postAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;
    final answersCol = FirebaseFirestore.instance
        .collection('queries')
        .doc(widget.queryId)
        .collection('answers');
    await answersCol.add({
      'author': _myName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _answerController.clear();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryDocStream = FirebaseFirestore.instance
        .collection('queries')
        .doc(widget.queryId)
        .snapshots();

    final answersStream = FirebaseFirestore.instance
        .collection('queries')
        .doc(widget.queryId)
        .collection('answers')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade200, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.author} posted a query',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(widget.text, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Likes & Answers buttons
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: queryDocStream,
            builder: (ctx, snap) {
              final likes = (snap.data?.data()?['likes'] as int?) ?? 0;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    onPressed: () => _toggleLike(likes),
                  ),
                  Text('$likes'),
                  const SizedBox(width: 24),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showAnswers = !_showAnswers),
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: Text(_showAnswers ? 'Hide Answers' : 'Answers'),
                  ),
                ],
              );
            },
          ),

          // Expandable answers section
          if (_showAnswers) ...[
            const Divider(),
            SizedBox(
              height: 150,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: answersStream,
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No answers yet.'));
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final a = docs[i].data();
                      return Text(
                        '${a['author']}: ${a['text']}',
                        style: const TextStyle(fontSize: 14),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: 'Write an answer...',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _postAnswer,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
