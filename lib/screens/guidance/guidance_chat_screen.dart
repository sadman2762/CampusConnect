import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../../../services/chat_service.dart';

class GuidanceChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  static const routeName = '/guidance_chat';

  const GuidanceChatScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
  }) : super(key: key);

  @override
  State<GuidanceChatScreen> createState() => _GuidanceChatScreenState();
}

class _GuidanceChatScreenState extends State<GuidanceChatScreen> {
  final _chatService = ChatService();
  final _controller = TextEditingController();
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final myId = FirebaseAuth.instance.currentUser?.uid;
    if (myId == null) return;
    final id = await _chatService.getOrCreateChat(myId, widget.peerId);
    setState(() {
      _chatId = id;
    });
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
            if (widget.peerAvatar != null)
              CircleAvatar(backgroundImage: AssetImage(widget.peerAvatar!))
            else
              const CircleAvatar(child: Icon(Icons.person)),
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

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[messages.length - 1 - i];
                          final text = msg['text'];
                          final senderId = msg['senderId'];
                          final isMe = senderId == myId;

                          final isFile = text.startsWith('[FILE] ');

                          final timestamp = msg['timestamp'] as Timestamp?;
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
                                  isFile
                                      ? _buildFileMessage(text)
                                      : Text(
                                          text,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
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
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickAndSendFile,
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
