// lib/screens/student_feed/widgets/feed_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/student_profile_screen.dart'; // Adjust path if needed

class FeedCard extends StatefulWidget {
  final String postId;
  final String studentId;
  final String name;
  final String avatarPath;
  final String content;

  const FeedCard({
    Key? key,
    required this.postId,
    required this.studentId,
    required this.name,
    required this.avatarPath,
    required this.content,
  }) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .collection('comments');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _commentsStream =>
      _commentsCol.orderBy('timestamp').snapshots();

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users') // ✅ Fixed path
        .doc(user.uid)
        .get();
    final profileData = userDoc.data() ?? {};

    final authorName = (profileData['name'] as String?)?.isNotEmpty == true
        ? profileData['name'] as String
        : (user.displayName ?? 'No Name');
    final authorAvatar =
        (profileData['profilePic'] as String?)?.isNotEmpty == true
            ? profileData['profilePic'] as String
            : (user.photoURL ?? '');

    await _commentsCol.add({
      'authorId': user.uid,
      'author': authorName,
      'avatar': authorAvatar,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.isNotEmpty) {
      return AssetImage(path);
    } else {
      return const AssetImage('assets/images/default_avatar.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StudentProfileScreen(studentId: widget.studentId),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _imageProvider(widget.avatarPath),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _commentsStream,
              builder: (ctx, snap) {
                final count = snap.data?.docs.length ?? 0;
                return TextButton.icon(
                  onPressed: () =>
                      setState(() => _showComments = !_showComments),
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: Text('Comments ($count)'),
                );
              },
            ),
            if (_showComments) ...[
              const Divider(),
              SizedBox(
                height: 140,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _commentsStream,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = docs[i].data();
                        final avatar = (c['avatar'] as String?) ?? '';
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: _imageProvider(avatar),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "${c['author']}: ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: c['text'] as String),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment…',
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _postComment,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
