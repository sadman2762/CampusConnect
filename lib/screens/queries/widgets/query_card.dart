import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryCard extends StatefulWidget {
  final String queryId;
  final String author;
  final String title;
  final String text;
  final String profilePicUrl;

  const QueryCard({
    Key? key,
    required this.queryId,
    required this.author,
    required this.title,
    required this.text,
    required this.profilePicUrl,
  }) : super(key: key);

  @override
  State<QueryCard> createState() => _QueryCardState();
}

class _QueryCardState extends State<QueryCard> {
  final _answerController = TextEditingController();
  bool _showAnswers = false;
  bool _alreadyLiked = false;
  int _likes = 0;

  User? get _me => FirebaseAuth.instance.currentUser;
  String get _myUid => _me?.uid ?? '';
  String get _myName => _me?.email?.split('@').first ?? 'Anonymous';

  Future<void> _checkIfLiked() async {
    if (_myUid.isEmpty) return;

    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('queries')
          .doc(widget.queryId)
          .collection('likes')
          .doc(_myUid)
          .get();

      setState(() {
        _alreadyLiked = likeDoc.exists;
      });

      print(
          '👍 Like check for ${widget.queryId} by $_myUid: ${likeDoc.exists}');
    } catch (e) {
      print('❌ Error checking like: $e');
    }
  }

  Future<void> _fetchLikes() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('queries')
          .doc(widget.queryId)
          .get();

      if (doc.exists) {
        setState(() {
          _likes = doc.data()?['likes'] ?? 0;
        });
        print('ℹ️ Likes for ${widget.queryId}: $_likes');
      }
    } catch (e) {
      print('❌ Error fetching likes: $e');
    }
  }

  /// STEP 1 Debugging: split update and set
  Future<void> _toggleLike() async {
    if (_alreadyLiked || _myUid.isEmpty) return;

    final queryRef =
        FirebaseFirestore.instance.collection('queries').doc(widget.queryId);
    final likeRef = queryRef.collection('likes').doc(_myUid);

    try {
      await queryRef.update({'likes': FieldValue.increment(1)});
      print('✔️ Likes field updated successfully');
    } catch (e) {
      print('❌ Failed to update likes field: $e');
    }

    try {
      await likeRef.set(
          {'likedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      print('✔️ Like document created successfully');
    } catch (e) {
      print('❌ Failed to create like document: $e');
    }

    setState(() {
      _alreadyLiked = true;
      _likes += 1;
    });
  }

  Future<void> _postAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _myUid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('queries')
          .doc(widget.queryId)
          .collection('answers')
          .add({
        'author': _myName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _answerController.clear();
      print('✅ Answer posted to ${widget.queryId}');
    } catch (e) {
      print('❌ Error posting answer: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _fetchLikes();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.profilePicUrl),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.author} posted a query',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _alreadyLiked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  color: _alreadyLiked ? Colors.blue : null,
                ),
                onPressed: _alreadyLiked ? null : _toggleLike,
              ),
              Text('$_likes'),
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: () => setState(() => _showAnswers = !_showAnswers),
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(_showAnswers ? 'Hide Answers' : 'Answers'),
              ),
            ],
          ),
          if (_showAnswers) ...[
            const Divider(),
            SizedBox(
              height: 150,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: answersStream,
                builder: (ctx, snap) {
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  if (docs.isEmpty)
                    return const Center(child: Text('No answers yet.'));
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final a = docs[i].data();
                      return Text('${a['author']}: ${a['text']}',
                          style: const TextStyle(fontSize: 14));
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
