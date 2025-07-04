import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ⚙️ STORAGE FETCH
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../guidance/guidance_screen.dart';
import '../guidance/guidance_chat_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  static const routeName = '/student_profile';
  final String studentId;

  const StudentProfileScreen({Key? key, required this.studentId})
      : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String _ordinalSuffix(String y) {
    switch (y) {
      case '1':
        return 'st';
      case '2':
        return 'nd';
      case '3':
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _sendConnectionRequest(String targetId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final connectionDoc =
          FirebaseFirestore.instance.collection('connections').doc(targetId);

      final docSnapshot = await connectionDoc.get();
      if (!docSnapshot.exists) {
        await connectionDoc.set({});
      }

      final connectionRef =
          connectionDoc.collection('requests').doc(currentUser.uid);

      final snapshot = await connectionRef.get();
      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request already sent.")),
        );
        return;
      }

      await connectionRef.set({
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      // 🔔 Add notification for the receiver
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(targetId)
          .collection('items')
          .add({
        'type': 'connection_request',
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'Someone',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection request sent!")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send request: ${e.toString()}")),
      );
    }
  }

  Future<int> _getAcceptedConnectionCount(String studentId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('connections')
        .doc(studentId)
        .collection('requests')
        .where('status', isEqualTo: 'accepted')
        .get();

    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwnProfile = widget.studentId == currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.studentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists)
            return const Center(child: Text("Student profile not found"));

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? 'Unknown';
          final email = data['email'] ?? '';

          // ⚙️ AVATAR: prefer photoURL, then legacy profilePic
          String rawAvatarField = data['photoURL'] as String? ?? '';
          if (rawAvatarField.isEmpty) {
            rawAvatarField = data['profilePic'] as String? ?? '';
          }
          // ⚙️ Fallback to Auth photoURL for your own profile
          if (rawAvatarField.isEmpty && isOwnProfile) {
            rawAvatarField = currentUser?.photoURL ?? '';
          }

          final bio = data['bio'] ?? '';
          final university = data['university'] ?? '';
          final year = data['year'] ?? '';
          final projects = data['projects']?.toString() ?? '0';
          final followers = data['followers']?.toString() ?? '0';
          final reviews = data['reviews']?.toString() ?? '0';

          // ⚙️ AVATAR: decide how to fetch
          Future<String> avatarUrlFuture;
          if (rawAvatarField.startsWith('http')) {
            avatarUrlFuture = Future.value(rawAvatarField);
          } else if (rawAvatarField.isNotEmpty) {
            avatarUrlFuture = FirebaseStorage.instance
                .ref('user_avatars/$rawAvatarField')
                .getDownloadURL();
          } else {
            avatarUrlFuture = Future.value('');
          }

          return FutureBuilder<String>(
            future: avatarUrlFuture,
            builder: (ctx, urlSnap) {
              final avatarUrl = urlSnap.data ?? '';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person_outline, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 10), // “Change Photo” removed
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (bio.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (university.isNotEmpty || year.isNotEmpty) ...[
                      Text(university,
                          style: Theme.of(context).textTheme.bodyMedium),
                      if (year.isNotEmpty)
                        Text(
                          '$year${_ordinalSuffix(year)} year',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 24),
                    ],
                    if (!isOwnProfile)
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('connections')
                            .doc(widget.studentId)
                            .collection('requests')
                            .doc(currentUser!.uid)
                            .snapshots(),
                        builder: (context, connSnap) {
                          final connData = connSnap.data?.data();
                          final status = connData?['status'];
                          Widget button;
                          if (status == 'pending') {
                            button = OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.hourglass_empty),
                              label: const Text("Pending"),
                            );
                          } else if (status == 'accepted') {
                            button = OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Connected"),
                            );
                          } else {
                            button = OutlinedButton.icon(
                              onPressed: () =>
                                  _sendConnectionRequest(widget.studentId),
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text("Connect"),
                            );
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Row(
                              children: [
                                Expanded(child: button),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final currentUid = FirebaseAuth
                                          .instance.currentUser!.uid;
                                      final peerId = widget.studentId;
                                      final peerName = name;
                                      // (you don’t need chatId here since the chat screen itself will compute it
                                      // the same way your guidance_screen.dart does)

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GuidanceChatScreen(
                                            peerId: peerId,
                                            peerName: peerName,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.message),
                                    label: const Text("Private Message"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: FutureBuilder<int>(
                        future: _getAcceptedConnectionCount(widget.studentId),
                        builder: (context, connSnap) {
                          final connCount = connSnap.connectionState ==
                                  ConnectionState.waiting
                              ? '...'
                              : connSnap.hasError
                                  ? '0'
                                  : connSnap.data.toString();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatCard(label: "Projects", value: projects),
                              _StatCard(
                                  label: "Connections",
                                  value: connCount), // 🟩 New stat added
                              _StatCard(label: "Reviews", value: reviews),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      "© 2025 4TY - all rights reserved",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
