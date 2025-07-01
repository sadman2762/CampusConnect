// lib/screens/guidance/guidance_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ⚙️ STORAGE FETCH

import '../profile/profile_screen.dart';
import 'guidance_chat_screen.dart';

class GuidanceScreen extends StatefulWidget {
  static const routeName = '/guidance';
  const GuidanceScreen({Key? key}) : super(key: key);

  @override
  _GuidanceScreenState createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  String? currentUserId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  Future<void> _respondToRequest(String requestId, bool accept) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('connections')
          .doc(currentUserId)
          .collection('requests')
          .doc(requestId);

      await docRef.update({'status': accept ? 'accepted' : 'rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(accept ? "Request accepted" : "Request rejected")),
      );
    } catch (e) {
      debugPrint("Failed to respond to request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getRegisteredUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .where((doc) {
          final email = doc['email'] ?? '';
          final name = email.split('@')[0];
          return name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      },
    );
  }

  Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> _getLastMessage(
      String chatId) {
    return FirebaseFirestore.instance
        .collection('guidance_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  String _prettyTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return TimeOfDay.fromDateTime(dt).format(context);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (now.year == dt.year) {
      return '${_monthName(dt.month)} ${dt.day}';
    } else {
      return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  /// Resolves a raw filename or URL to a full avatar URL.
  Future<String> _resolveAvatarUrl(String raw) async {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    try {
      return await FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child(raw)
          .getDownloadURL();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: Drawer(child: Center(child: Text('Top Peers Coming Soon'))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'One-to-One Guidance',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Request personalized academic support from peers.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for peer',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Chats'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- Chats Tab ---
                  StreamBuilder<List<QueryDocumentSnapshot>>(
                    stream: _getRegisteredUsers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!;
                      if (users.isEmpty) {
                        return const Center(
                            child: Text('No registered peers found.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final userDoc = users[i];
                          final uid = userDoc.id;
                          final email = userDoc['email'] ?? 'unknown@email.com';
                          final name = email.split('@')[0];
                          final data = userDoc.data() as Map<String, dynamic>;
                          final rawAvatar = data['profilePic'] as String? ?? '';
                          final chatId = _getChatId(currentUserId!, uid);

                          return StreamBuilder<
                              QueryDocumentSnapshot<Map<String, dynamic>>?>(
                            stream: _getLastMessage(chatId),
                            builder: (context, msgSnapshot) {
                              String lastText = 'No messages yet';
                              String formattedTime = '';

                              if (msgSnapshot.hasData &&
                                  msgSnapshot.data != null) {
                                final msgData = msgSnapshot.data!.data();
                                if (msgData != null) {
                                  lastText = msgData['text'] ?? lastText;
                                  formattedTime =
                                      _prettyTime(msgData['timestamp']);
                                }
                              }

                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  tileColor: Colors.pink.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: FutureBuilder<String>(
                                    // ⚙️ resolve avatar
                                    future: _resolveAvatarUrl(rawAvatar),
                                    builder: (ctx, snap2) {
                                      final url = snap2.data;
                                      if (url != null && url.isNotEmpty) {
                                        return CircleAvatar(
                                          backgroundImage: NetworkImage(url),
                                        );
                                      }
                                      return const CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/profile.jpg'),
                                      );
                                    },
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (formattedTime.isNotEmpty)
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    lastText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GuidanceChatScreen(
                                          peerId: uid,
                                          peerName: name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  // --- Requests Tab ---
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('connections')
                        .doc(currentUserId)
                        .collection('requests')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data?.docs ?? [];
                      if (requests.isEmpty) {
                        return const Center(
                          child: Text('No connection requests yet.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final senderId = request['senderId'];
                          return FutureBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(senderId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const SizedBox();
                              }
                              final user = userSnapshot.data!.data()!;
                              final name = user['name'] ?? 'Unknown';
                              final rawAvatar = user['profilePic'] ?? '';

                              return ListTile(
                                leading: FutureBuilder<String>(
                                  // ⚙️ resolve avatar
                                  future: _resolveAvatarUrl(rawAvatar),
                                  builder: (ctx, snap3) {
                                    final url = snap3.data;
                                    if (url != null && url.isNotEmpty) {
                                      return CircleAvatar(
                                        backgroundImage: NetworkImage(url),
                                      );
                                    }
                                    return const CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/profile.jpg'));
                                  },
                                ),
                                title: Text(name),
                                subtitle:
                                    const Text("Wants to connect with you"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () =>
                                          _respondToRequest(request.id, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _respondToRequest(request.id, false),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                color: _tabController.index == 0 ? theme.primaryColor : null,
                onPressed: () => setState(() => _tabController.index = 0),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.how_to_reg_outlined),
                color: _tabController.index == 1 ? theme.primaryColor : null,
                onPressed: () => setState(() => _tabController.index = 1),
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
}
