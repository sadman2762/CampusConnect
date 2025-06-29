import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeGroupMessages() async {
  final firestore = FirebaseFirestore.instance;
  final groupsSnapshot = await firestore.collection('groups').get();

  for (final doc in groupsSnapshot.docs) {
    final groupName = doc.id;
    final messagesCol =
        firestore.collection('groups').doc(groupName).collection('messages');

    final messagesSnapshot = await messagesCol.limit(1).get();
    if (messagesSnapshot.docs.isEmpty) {
      await messagesCol.add({
        'author': 'system',
        'avatar': 'assets/images/default.jpg',
        'text': 'Welcome to the $groupName group!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Initialized group: $groupName');
    }
  }
}
