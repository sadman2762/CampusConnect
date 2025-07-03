import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedResourcesScreen extends StatefulWidget {
  final String groupName;

  const SharedResourcesScreen({super.key, required this.groupName});

  @override
  State<SharedResourcesScreen> createState() => _SharedResourcesScreenState();
}

class _SharedResourcesScreenState extends State<SharedResourcesScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sharedDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchSharedFiles();
  }

  Future<void> _fetchSharedFiles() async {
    print('📂 Loading shared files for group: ${widget.groupName}');

    final snap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupName)
        .collection('messages')
        .where('type', whereIn: ['image', 'file']) // ✅ Only media types
        .orderBy('timestamp', descending: true)
        .get();

    print('📦 Total fetched: ${snap.docs.length}');

    for (var doc in snap.docs) {
      print('👉 ${doc.data()}');
    }

    if (mounted) {
      setState(() {
        _sharedDocs = snap.docs.where((doc) {
          final data = doc.data();
          final hasUrl =
              data['url'] != null && (data['url'] as String).isNotEmpty;
          final hasFileName = data['fileName'] != null &&
              (data['fileName'] as String).trim().isNotEmpty;
          return hasUrl && hasFileName;
        }).toList();
      });
    }
  }

  Icon _getFileIcon(String fileName, String type) {
    if (type == 'image') return const Icon(Icons.image);
    if (fileName.endsWith('.pdf')) return const Icon(Icons.picture_as_pdf);
    if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return const Icon(Icons.slideshow);
    }
    return const Icon(Icons.insert_drive_file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Resources'),
        backgroundColor: Colors.pink.shade400,
      ),
      body: _sharedDocs.isEmpty
          ? const Center(child: Text('No shared files found.'))
          : ListView.separated(
              itemCount: _sharedDocs.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final data = _sharedDocs[i].data();
                final fileNameRaw = (data['fileName'] as String?)?.trim();
                final displayName = (fileNameRaw == null || fileNameRaw.isEmpty)
                    ? 'Untitled'
                    : fileNameRaw;

                final url = data['url'];
                final type = data['type'] ?? 'file';

                return ListTile(
                  leading: _getFileIcon(displayName, type),
                  title: Text(displayName),
                  onTap: () async {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open file')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
