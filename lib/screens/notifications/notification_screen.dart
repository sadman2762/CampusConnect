import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    final notificationsRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(currentUser.uid)
        .collection('items')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final type = data['type'];
              final senderName = data['senderName'] ?? 'Someone';
              final seen = data['seen'] ?? false;

              String message = 'You have a new notification';
              if (type == 'connection_request') {
                message = '$senderName sent you a connection request';
              }

              return ListTile(
                title: Text(message),
                trailing: seen
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.mark_email_read),
                        onPressed: () {
                          docs[index].reference.update({'seen': true});
                        },
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
