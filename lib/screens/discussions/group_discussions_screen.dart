// lib/screens/discussions/group_discussions_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ⚙️ STORAGE FETCH
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'shared_resources_screen.dart'; // or the correct relative path

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

  /// Resolve raw avatar string: if URL already, return it; else fetch from Storage
  Future<String> _resolveAvatarUrl(String avatarPath) async {
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }
    if (avatarPath.isEmpty) {
      return 'assets/images/default.jpg';
    }
    try {
      return await FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child(avatarPath)
          .getDownloadURL();
    } catch (e) {
      return 'assets/images/default.jpg';
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _me == null) return;
    final uid = _me!.uid;
    // reuse your existing _getUserAvatar logic if desired;
    // here we store raw uid.jpg so other clients can resolve too
    await _messagesCol.add({
      'author': _myName,
      'avatar': '$uid.jpg', // store filename, not full URL
      'text': text,
      'timestamp': Timestamp.now(),
    });
    _controller.clear();
  }

  Future<int> _countSharedResources() async {
    final snap = await _messagesCol
        .where('type', whereIn: ['image', 'file', 'doc']) // shared media types
        .get();
    return snap.size;
  }

  void _showPollDialog() {
    final questionController = TextEditingController();
    final optionControllers = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a Poll'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Poll Question',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...optionControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                          ),
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          optionControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Option'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final question = questionController.text.trim();
                final options = optionControllers
                    .map((c) => c.text.trim())
                    .where((o) => o.isNotEmpty)
                    .toList();

                if (question.isEmpty || options.length < 2 || _me == null)
                  return;

                await _messagesCol.add({
                  'author': _myName,
                  'avatar': '${_me!.uid}.jpg',
                  'text': question,
                  'type': 'poll',
                  'options': options,
                  'votes': {},
                  'timestamp': Timestamp.now(),
                });

                Navigator.pop(context);
              },
              child: const Text('Send Poll'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || _me == null) return;

    final uid = _me!.uid;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

    final ref = FirebaseStorage.instance
        .ref()
        .child('group_images')
        .child(widget.groupName)
        .child(fileName);

    try {
      UploadTask uploadTask;

      // ✅ Handle web vs. mobile
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        uploadTask = ref.putData(bytes); // ✅ For web
      } else {
        final file = File(pickedFile.path);
        uploadTask = ref.putFile(file); // ✅ For mobile
      }

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      print('✅ Image URL: $imageUrl');

      await _messagesCol.add({
        'author': _myName,
        'avatar': '$uid.jpg',
        'text': '[IMAGE] $fileName\n$imageUrl',
        'timestamp': Timestamp.now(),
        'type': 'image',
        'url': imageUrl,
        'fileName': fileName,
      });
    } catch (e, stack) {
      print('❌ Upload failed: $e');
      print(stack);
    }
  }

  // 📄 Function to pick and send document file from local storage
  Future<void> _pickAndSendDocument() async {
    try {
      print('📎 Document button tapped');
      if (_me == null) return;

      final result = await FilePicker.platform.pickFiles();
      if (result == null) {
        print('❌ User canceled file picking');
        return;
      }

      final picked = result.files.first;
      print('🗂 Picked file: ${picked.name}');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      final ref = FirebaseStorage.instance
          .ref()
          .child('group_docs')
          .child(widget.groupName)
          .child(fileName);

      UploadTask uploadTask;

      if (kIsWeb) {
        if (picked.bytes == null) {
          print('❌ File bytes are null on web');
          return;
        }
        uploadTask = ref.putData(picked.bytes!);
      } else {
        final file = File(picked.path!);
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();
      print('✅ Uploaded to: $fileUrl');

      await _messagesCol.add({
        'author': _myName,
        'avatar': '${_me!.uid}.jpg',
        'text': '[DOC] $fileName\n$fileUrl',
        'timestamp': Timestamp.now(),
        'type': 'file',
        'url': fileUrl,
        'fileName': fileName,
      });
    } catch (e, stack) {
      print('❌ Error during document send: $e');
      print(stack);
    }
  }

  void _showReactionPicker(String docId) async {
    final emoji = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('React with emoji'),
        content: Wrap(
          spacing: 12,
          children: ['👍', '❤️', '😂', '🎉', '😢', '🔥'].map((e) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, e),
              child: Text(e, style: const TextStyle(fontSize: 24)),
            );
          }).toList(),
        ),
      ),
    );

    if (emoji != null && _me != null) {
      final uid = _me!.uid;

      try {
        final docSnap = await _messagesCol.doc(docId).get();
        if (!docSnap.exists) {
          print('❌ Message document not found');
          return;
        }

        final data = docSnap.data();
        if (data == null) {
          print('❌ Message data is null');
          return;
        }

        final reactionsRaw = data['reactions'];
        final Map<String, dynamic> reactions =
            reactionsRaw is Map<String, dynamic>
                ? Map<String, dynamic>.from(reactionsRaw)
                : {};

        print('🔄 Before: $reactions');

        if (reactions[uid] == emoji) {
          reactions.remove(uid); // unreact
        } else {
          reactions[uid] = emoji; // set/change
        }

        print('🔁 After: $reactions');

        await _messagesCol.doc(docId).update({'reactions': reactions});
        print('✅ Reaction saved to Firestore');
      } catch (e, stack) {
        print('❌ Failed to update reaction: $e');
        print(stack);

        // Optional fallback: force set if needed
        /*
      await _messagesCol.doc(docId).set({
        'reactions': {uid: emoji},
      }, SetOptions(merge: true));
      */
      }
    }
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
                      // 🔄 Replaced title + search layout to a single row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 👤 Group Name
                          Text(
                            widget.groupName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 🔍 Search Field with Fixed Width
                          SizedBox(
                            width: 220, // adjust as needed
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search messages...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 📂 Shared Resources Button with Count
                          FutureBuilder<int>(
                            future: _countSharedResources(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.folder_shared_outlined),
                                    tooltip: 'Shared Resources',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SharedResourcesScreen(
                                            groupName: widget.groupName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
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
                            final query = _searchController.text.toLowerCase();
                            final allMessages = snap.data?.docs ?? [];

// ✅ Apply search filter if there's a query
                            final messages = query.isEmpty
                                ? allMessages
                                : allMessages.where((doc) {
                                    final data = doc.data();
                                    final text = (data['text'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    return text.contains(query);
                                  }).toList();

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
                                final rawAvatar = m['avatar'] as String;
                                return FutureBuilder<String>(
                                  future: _resolveAvatarUrl(rawAvatar),
                                  builder: (ctx2, urlSnap) {
                                    final url = urlSnap.data ?? '';
                                    final docId = messages[i]
                                        .id; // ✅ get Firestore doc ID

                                    return GestureDetector(
                                      behavior: HitTestBehavior
                                          .opaque, // ✅ Ensures it registers taps
                                      onTap: () => _showReactionPicker(docId),
                                      child: _MessageBubble(
                                        author: m['author'] as String,
                                        avatarPath: url,
                                        text: m['text'] as String,
                                        type: m['type'] as String?, // ✅ NEW
                                        url: m['url'] as String?, // ✅ NEW
                                        messageId:
                                            messages[i].id, // ✅ for updating
                                        groupName: widget.groupName,
                                        options: m['options']
                                            as List<dynamic>?, // 🆕
                                        votes: m['votes'] != null &&
                                                m['votes']
                                                    is Map<String, dynamic>
                                            ? Map<String, dynamic>.from(
                                                m['votes'])
                                            : null,
                                        fileName: m['fileName']
                                            as String?, // 📁 pass fileName here
                                        reactions: m['reactions'] != null &&
                                                m['reactions']
                                                    is Map<String, dynamic>
                                            ? Map<String, dynamic>.from(
                                                m['reactions'])
                                            : null,
                                      ),
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
                    onPressed: _pickAndSendImage,
                  ),
                  // 📎 Document picker button
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickAndSendDocument, // Will define this next
                  ),
                  IconButton(
                    icon: const Icon(Icons.poll_outlined), // 🗳️ Create Poll
                    tooltip: 'Create Poll',
                    onPressed: _showPollDialog, // ➕ We define this next
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
                                title: Text(data[i]['name']),
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
                    title: Text(_filteredGroups[i]),
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
    'General Chat',
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
  final String author,
      avatarPath,
      text; // avatarPath now always full URL or asset path
  final Map<String, dynamic>? reactions; // ✅ NEW
  final String? type, url; // ✅ NEW: for image support
  final String? fileName; // 📁 NEW
  final List<dynamic>? options;
  final Map<String, dynamic>? votes;
  final String? messageId;
  final String groupName;
  const _MessageBubble({
    required this.author,
    required this.avatarPath,
    required this.text,
    this.type,
    this.url,
    this.fileName,
    this.reactions, // ✅ NEW
    this.options,
    this.votes,
    required this.messageId,
    required this.groupName,
  });

  String _getFileIcon(String fileName) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.pdf')) return '📕';
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return '📄';
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return '📊';
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return '📈';
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png'))
      return '🖼️';
    return '📁';
  }

  Widget _buildPollContent(BuildContext context) {
    final List<dynamic> optionsRaw = options ?? [];
    final Map<String, dynamic> voteMap = votes ?? {};
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userVote = uid != null ? voteMap[uid] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...List.generate(optionsRaw.length, (index) {
          final count = voteMap.values.where((v) => v == index).length;
          final isVoted = userVote == index;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isVoted ? Colors.green.shade100 : Colors.grey.shade200,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed:
                  userVote == null ? () => _submitVote(context, index) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(optionsRaw[index].toString())),
                  if (voteMap.isNotEmpty)
                    Text('$count vote${count != 1 ? 's' : ''}'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _submitVote(BuildContext context, int selectedIndex) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || type != 'poll' || messageId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupName)
          .collection('messages')
          .doc(messageId)
          .update({
        'votes.$uid': selectedIndex,
      });
      print('✅ Vote recorded for $uid');
    } catch (e) {
      print('❌ Failed to submit vote: $e');
    }
  }

  Widget buildReactions(Map<String, dynamic>? reactionsMap) {
    if (reactionsMap == null || reactionsMap.isEmpty) return SizedBox();

    final emojiCount = <String, int>{};
    reactionsMap.values.forEach((emoji) {
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    });

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: emojiCount.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${entry.key} ${entry.value}'),
          );
        }).toList(),
      ),
    );
  }

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
                type == 'image' && url != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      )
                    : type == 'file' && url != null
                        ? GestureDetector(
                            onTap: () async {
                              if (await canLaunchUrl(Uri.parse(url!))) {
                                launchUrl(Uri.parse(url!));
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  _getFileIcon(fileName ?? ''),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    fileName ?? 'Document',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : type == 'poll'
                            ? _buildPollContent(context)
                            : Text(text),
                buildReactions(reactions),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
