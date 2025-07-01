// lib/screens/discussions/guidance_chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ⚙️ STORAGE FETCH
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

import '../../../services/chat_service.dart';

class GuidanceChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  // remove peerAvatar parameter, we'll fetch from Firestore

  static const routeName = '/guidance_chat';

  GuidanceChatScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
  }) : super(key: key);

  @override
  State<GuidanceChatScreen> createState() => _GuidanceChatScreenState();
}

class _GuidanceChatScreenState extends State<GuidanceChatScreen> {
  final _chatService = ChatService();
  final _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // 📸 image picker
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  String? _chatId;
  late Future<String> _peerAvatarUrl; // will hold resolved URL

  @override
  void initState() {
    super.initState();
    _initChat();
    _peerAvatarUrl = _loadPeerAvatar(); // fetch on init
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _initChat() async {
    final myId = FirebaseAuth.instance.currentUser?.uid;
    if (myId == null) return;
    final chatId = _getChatId(myId, widget.peerId);
    setState(() => _chatId = chatId);
  }

  /// Fetches the raw avatar filename from Firestore and resolves URL
  Future<String> _loadPeerAvatar() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.peerId)
          .get();
      final raw = doc.data()?['profilePic'] as String? ?? '';
      return _resolveAvatarUrl(raw);
    } catch (_) {
      return '';
    }
  }

  /// If [raw] is a full URL, returns it; if filename, fetches from Storage
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

  void _sendMessage() async {
    final text = _controller.text.trim();
    final senderId = FirebaseAuth.instance.currentUser?.uid;
    if (text.isEmpty || _chatId == null || senderId == null) return;

    await _chatService.sendMessage(
      chatId: _chatId!,
      senderId: senderId,
      text: text,
    );

    _controller.clear();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) return;

      final dir = await getTemporaryDirectory(); // 📁 temp dir
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      setState(() => _isRecording = true);
    } else {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (path == null) return;

      final file = File(path);
      final bytes = await file.readAsBytes();
      final fileName = path.split('/').last;

      final ref =
          FirebaseStorage.instance.ref().child('chat_files/$_chatId/$fileName');
      await ref.putData(bytes);
      final audioUrl = await ref.getDownloadURL();

      final senderId = FirebaseAuth.instance.currentUser?.uid;
      if (_chatId != null && senderId != null) {
        await _chatService.sendMessage(
          chatId: _chatId!,
          senderId: senderId,
          text: '[AUDIO] $fileName\n$audioUrl',
        );
      }
    }
  }

  Widget _buildImageMessage(String text) {
    final parts = text.split('\n');
    if (parts.length != 2) return Text(text);
    final url = parts[1];

    return GestureDetector(
      onTap: () => _openFileUrl(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioMessage(String text) {
    final parts = text.split('\n');
    if (parts.length != 2) return Text(text);
    final url = parts[1];
    final player = AudioPlayer();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            try {
              await player.setUrl(url);
              player.play();
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to play audio')),
              );
            }
          },
        ),
        const Text("Voice Message"),
      ],
    );
  }

  Future<void> _pickAndSendImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final fileName = pickedFile.name;

    final ref =
        FirebaseStorage.instance.ref().child('chat_files/$_chatId/$fileName');
    await ref.putData(bytes);

    final imageUrl = await ref.getDownloadURL();

    final senderId = FirebaseAuth.instance.currentUser?.uid;
    if (_chatId != null && senderId != null) {
      await _chatService.sendMessage(
        chatId: _chatId!,
        senderId: senderId,
        text: '[IMAGE] $fileName\n$imageUrl', // tag as image
      );
    }
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      final Uint8List fileBytes = result.files.single.bytes!;
      final String fileName = result.files.single.name;

      final ref =
          FirebaseStorage.instance.ref().child('chat_files/$_chatId/$fileName');

      await ref.putData(fileBytes);
      final fileUrl = await ref.getDownloadURL();

      final senderId = FirebaseAuth.instance.currentUser?.uid;
      if (_chatId != null && senderId != null) {
        await _chatService.sendMessage(
          chatId: _chatId!,
          senderId: senderId,
          text: '[FILE] $fileName\n$fileUrl',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder<String>(
              // load & show peer avatar
              future: _peerAvatarUrl,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final url = snap.data;
                if (url != null && url.isNotEmpty) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(url),
                  );
                }
                return const CircleAvatar(
                  child: Icon(Icons.person),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(widget.peerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getMessagesStream(_chatId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;
                      final currentUserId =
                          FirebaseAuth.instance.currentUser?.uid;

                      for (var msg in messages) {
                        final data = msg.data() as Map<String, dynamic>;
                        final seenList =
                            data.containsKey('seenBy') && data['seenBy'] is List
                                ? List<String>.from(data['seenBy'])
                                : <String>[];

                        final senderId = data['senderId'];

                        if (!seenList.contains(currentUserId) &&
                            senderId != currentUserId) {
                          msg.reference.update({
                            'seenBy': FieldValue.arrayUnion([currentUserId])
                          });

                          print(
                              '✅ Marked message ${msg.id} as seen by $currentUserId');
                        }
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[messages.length - 1 - i];
                          final data = msg.data() as Map<String, dynamic>;

                          final text = data['text'];
                          final senderId = data['senderId'];
                          final isMe = senderId ==
                              FirebaseAuth.instance.currentUser?.uid;

                          final isFile = text.startsWith('[FILE] ');
                          final isImage = text.startsWith('[IMAGE] ');
                          final isAudio = text.startsWith('[AUDIO] ');

                          final List<String> seenList =
                              data.containsKey('seenBy') &&
                                      data['seenBy'] is List
                                  ? List<String>.from(data['seenBy'])
                                  : <String>[];

                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeText = timestamp != null
                              ? DateFormat('hh:mm a').format(timestamp.toDate())
                              : '';

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (isImage)
                                    _buildImageMessage(text)
                                  else if (isFile)
                                    _buildFileMessage(text)
                                  else if (isAudio)
                                    _buildAudioMessage(text)
                                  else
                                    Text(text,
                                        style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(timeText,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  if (isMe)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          timeText,
                                          style: const TextStyle(
                                              fontSize: 10, color: Colors.grey),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            seenList.length >= 1
                                                ? Icons.done_all
                                                : Icons.check,
                                            size: 14,
                                            color: seenList.length >= 1
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ],
                                      ],
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickAndSendImage, // 📸 New method
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickAndSendFile,
                ),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: _toggleRecording,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(String text) {
    final parts = text.split('\n');
    if (parts.length != 2) return Text(text);
    final filename = parts[0].replaceFirst('[FILE] ', '');
    final url = parts[1];

    return GestureDetector(
      onTap: () => _openFileUrl(url),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              filename,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFileUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the file URL')),
      );
    }
  }
}
