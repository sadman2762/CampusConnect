import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getRegisteredUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
      (snapshot) {
        return snapshot.docs.where((doc) => doc.id != currentUserId).toList();
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
                          final user = users[i];
                          final uid = user.id;
                          final email = user['email'] ?? 'unknown@email.com';
                          final name = email.split('@')[0];
                          final data = user.data() as Map<String, dynamic>;
                          final avatar = data['photoURL'];
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
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        avatar != null && avatar.isNotEmpty
                                            ? NetworkImage(avatar)
                                            : const AssetImage(
                                                    'assets/images/profile.jpg')
                                                as ImageProvider,
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
                                          peerAvatar: avatar,
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
                  const Center(
                    child: Text(
                      'No requests yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
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
