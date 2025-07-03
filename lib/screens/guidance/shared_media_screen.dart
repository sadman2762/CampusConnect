import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedMediaScreen extends StatefulWidget {
  final String chatId;

  const SharedMediaScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  State<SharedMediaScreen> createState() => _SharedMediaScreenState();
}

class _SharedMediaScreenState extends State<SharedMediaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    print('✅ SharedMediaScreen mounted with chatId = ${widget.chatId}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Media'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: 'Images'),
            Tab(icon: Icon(Icons.description), text: 'Docs'),
            Tab(icon: Icon(Icons.insert_drive_file), text: 'Files'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaList(type: 'image'),
          _buildMediaList(type: 'doc'),
          _buildMediaList(type: 'file'),
        ],
      ),
    );
  }

  Widget _buildMediaList({required String type}) {
    print('📸 Building media list for type: $type');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guidance_chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snap.data?.docs ?? [];

        print(
            'SharedMediaScreen: found ${allDocs.length} messages of type $type');

        final docs = allDocs.where((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final isValid = data['url'] != null &&
                data['fileName'] != null &&
                data['timestamp'] != null &&
                data['url'] is String &&
                data['fileName'] is String &&
                data['timestamp'] is Timestamp;
            if (!isValid) {
              print('❌ Skipping ${doc.id} — missing or invalid fields');
            }
            return isValid;
          } catch (e) {
            print('❌ Skipping ${doc.id} — cast error: $e');
            return false;
          }
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('No media found.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final url = data['url']!;
            final fileName = data['fileName']!;

            if (type == 'image') {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(url),
              );
            } else {
              return ListTile(
                leading: Icon(type == 'doc'
                    ? Icons.description
                    : Icons.insert_drive_file),
                title: Text(fileName),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(url, overflow: TextOverflow.fade),
                ),
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}
