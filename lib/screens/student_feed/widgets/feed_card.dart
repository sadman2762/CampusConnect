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
  final Map<String, dynamic>? likes;
  final String currentUserId;
  final String type;
  final Map<String, dynamic>? votes;

  const FeedCard({
    Key? key,
    required this.postId,
    required this.studentId,
    required this.name,
    required this.avatarPath,
    required this.content,
    required this.likes,
    required this.currentUserId,
    required this.type,
    required this.votes,
  }) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
  bool get _isLiked => widget.likes?[widget.currentUserId] == true;
  int get _likeCount => widget.likes?.length ?? 0;
  String? get _myVote => widget.votes?[widget.currentUserId] as String?;

  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .collection('comments');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _commentsStream =>
      _commentsCol.orderBy('timestamp').snapshots();

  Future<void> _vote(String option) async {
    final docRef =
        FirebaseFirestore.instance.collection('feed').doc(widget.postId);

    await docRef.update({
      'votes.${widget.currentUserId}': option,
    });
  }

  int _voteCount(String type) {
    return widget.votes?.values.where((v) => v == type).length ?? 0;
  }

  int get _totalVotes => widget.votes?.length ?? 0;

  double _votePercentage(String type) {
    final count = _voteCount(type);
    if (_totalVotes == 0) return 0;
    return (count / _totalVotes);
  }

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

  Future<void> _toggleLike() async {
    final docRef =
        FirebaseFirestore.instance.collection('feed').doc(widget.postId);

    final isCurrentlyLiked = widget.likes?[widget.currentUserId] == true;

    await docRef.update({
      'likes.${widget.currentUserId}':
          isCurrentlyLiked ? FieldValue.delete() : true,
    });
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

  Future<void> _showVoteHistory() async {
    final voteMap = widget.votes ?? {};
    if (voteMap.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchVoterProfiles(voteMap),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final voters = snap.data ?? [];
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: voters.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final voter = voters[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(voter['avatar']),
                  ),
                  title: Text(voter['name']),
                  subtitle: Text(
                    _voteLabel(voter['vote']),
                    style: TextStyle(
                      color: voter['vote'] == 'going'
                          ? Colors.green
                          : voter['vote'] == 'maybe'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchVoterProfiles(Map votes) async {
    final List<Map<String, dynamic>> results = [];

    for (final entry in votes.entries) {
      final uid = entry.key;
      final vote = entry.value;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final data = userDoc.data() ?? {};
      results.add({
        'name': data['name'] ?? 'Unknown',
        'avatar': data['profilePic'] ?? '',
        'vote': vote,
      });
    }

    return results;
  }

  String _voteLabel(String vote) {
    switch (vote) {
      case 'going':
        return 'Going ✅';
      case 'not_going':
        return 'Not Going ❌';
      case 'maybe':
        return 'Maybe ❓';
      default:
        return vote;
    }
  }

  Widget _pollOption(String type, IconData icon, String label) {
    final isSelected = _myVote == type;
    final percentage = _votePercentage(type);
    final percentText = (_votePercentage(type) * 100).toStringAsFixed(0);

    return InkWell(
      onTap: () => _vote(type),
      child: Stack(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 18, color: isSelected ? Colors.white : Colors.black),
                const SizedBox(width: 8),
                Text(
                  '$label (${_voteCount(type)}) - $percentText%',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$_likeCount likes'),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.type == 'event') ...[
              const SizedBox(height: 8),
              Column(
                children: [
                  _pollOption('going', Icons.check_circle, 'Going'),
                  const SizedBox(height: 6),
                  _pollOption('not_going', Icons.cancel, 'Not Going'),
                  const SizedBox(height: 6),
                  _pollOption('maybe', Icons.help_outline, 'Maybe'),
                ],
              ),
              TextButton.icon(
                onPressed: _showVoteHistory,
                icon: const Icon(Icons.people_outline),
                label: const Text('See voters'),
              ),
            ],
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
