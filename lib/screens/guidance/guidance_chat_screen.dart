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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'shared_media_screen.dart';

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
  final Map<String, String> _userNameCache = {};
  final Map<String, String> _translatedMessages = {};
  final Map<String, bool> _translating = {};
  String? _hoveredMessageId;
  String? _editingMessageId;
  final Map<String, TextEditingController> _editControllers = {};
  bool isSearching = false;
  String searchKeyword = '';

  String? _chatId;
  late Future<String> _peerAvatarUrl; // will hold resolved URL

  @override
  void initState() {
    super.initState();
    _initChat();
    _peerAvatarUrl = _loadPeerAvatar();

    // Listen once and mark seen exactly once per message
    _chatService.getMessagesStream(_chatId!).listen((snapshot) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      for (var msg in snapshot.docs) {
        final data = msg.data() as Map<String, dynamic>;
        final seenList = (data['seenBy'] as List?)?.cast<String>() ?? [];
        final senderId = data['senderId'] as String?;
        if (currentUserId != null &&
            senderId != currentUserId &&
            !seenList.contains(currentUserId)) {
          msg.reference.update({
            'seenBy': FieldValue.arrayUnion([currentUserId])
          });
        }
      }
    });
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

  Future<String> _getUserName(String uid) async {
    if (_userNameCache.containsKey(uid)) {
      return _userNameCache[uid]!;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = doc.data()?['name'] ?? uid;
      _userNameCache[uid] = name;
      return name;
    } catch (e) {
      return uid;
    }
  }

  String cleanMarkdown(String raw) {
    String text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Fix bullets: Replace "*   " or "*  " with "* "
    text = text.replaceAllMapped(
      RegExp(r'^\*\s{2,}', multiLine: true),
      (m) => '* ',
    );

    // Ensure blank lines between paragraphs/lists for markdown parsing
    text = text.replaceAllMapped(
      RegExp(r'([^\n])\n([^\n])'),
      (m) => '${m.group(1)}\n\n${m.group(2)}',
    );

    // Fix smart quotes if Gemini used them
    text = text.replaceAll('“', '"').replaceAll('”', '"');

    // Escape markdown characters only if not already escaped
    text = text.replaceAllMapped(
      RegExp(r'(?<!\\)([*_])'),
      (m) => '\\${m.group(1)}',
    );

    return text.trim();
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

  void _showReactionPicker(BuildContext context, String messageId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final selectedReaction = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("React to message"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, emoji),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedReaction != null) {
      await _updateReaction(messageId, userId, selectedReaction);
    }
  }

  /// Shows a context menu anchored to the message bubble.
  /// Now takes the message’s current text so “Edit” can prefill the editor.
  void _openMessageMenu(
    BuildContext context,
    String messageId,
    bool isMe,
    String currentText, // ← new parameter
  ) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        100, 100, // you can tweak these to better anchor at the button
        0,
        0,
      ),
      items: [
        const PopupMenuItem(value: 'reaction', child: Text('Add Reaction')),
        if (isMe) const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (isMe) const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      switch (value) {
        case 'reaction':
          _showReactionPicker(context, messageId);
          break;
        case 'edit':
          _enterEditMode(messageId, currentText); // ← now passing the text
          break;
        case 'delete':
          _confirmDeletion(messageId);
          break;
      }
    });
  }

  Future<void> _confirmDeletion(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      FirebaseFirestore.instance
          .collection('guidance_chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    }
  }

  void _enterEditMode(String messageId, String currentText) {
    _editControllers[messageId] = TextEditingController(text: currentText);
    setState(() => _editingMessageId = messageId);
  }

  Future<void> _saveEdit(String messageId) async {
    final controller = _editControllers[messageId];
    if (controller == null) return;
    final newText = controller.text.trim();
    if (newText.isNotEmpty && _chatId != null) {
      await FirebaseFirestore.instance
          .collection('guidance_chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .update({'text': newText});
    }
    _cancelEdit(messageId);
  }

  void _cancelEdit(String messageId) {
    _editControllers[messageId]?.dispose();
    _editControllers.remove(messageId);
    setState(() => _editingMessageId = null);
  }

  Future<void> _updateReaction(
      String messageId, String userId, String emoji) async {
    if (_chatId == null) return;

    final messageRef = FirebaseFirestore.instance
        .collection('guidance_chats')
        .doc(_chatId!)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();
    final data = doc.data();
    if (data == null) return;

    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final currentReaction = reactions[userId];

    if (currentReaction == emoji) {
      reactions.remove(userId);
    } else {
      reactions[userId] = emoji;
    }

    await messageRef.update({'reactions': reactions});
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
        await FirebaseFirestore.instance
            .collection('guidance_chats')
            .doc(_chatId!)
            .collection('messages')
            .add({
          'type': 'image',
          'url': audioUrl,
          'fileName': fileName,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
          'seenBy': [],
          'reactions': {},
        });
      }
    }
  }

  Widget _buildImageMessage(String url) {
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

  Widget _buildAudioMessage(String url) {
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
      await FirebaseFirestore.instance
          .collection('guidance_chats')
          .doc(_chatId!)
          .collection('messages')
          .add({
        'type': 'image',
        'url': imageUrl,
        'fileName': fileName,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
        'seenBy': [],
        'reactions': {},
      });
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
        await FirebaseFirestore.instance
            .collection('guidance_chats')
            .doc(_chatId!)
            .collection('messages')
            .add({
          'type': 'doc',
          'url': fileUrl,
          'fileName': fileName,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
          'seenBy': [],
          'reactions': {},
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  setState(() => searchKeyword = value);
                },
              )
            : Row(
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
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                searchKeyword = '';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.perm_media_rounded), // 📁 Shared Media icon
            tooltip: 'Shared Media',
            onPressed: () {
              if (_chatId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SharedMediaScreen(chatId: _chatId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please wait, chat is still loading...')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // You can add options here later
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: (searchKeyword.isEmpty)
                        ? _chatService.getMessagesStream(_chatId!)
                        : FirebaseFirestore.instance
                            .collection('guidance_chats')
                            .doc(_chatId!)
                            .collection('messages')
                            .orderBy('text')
                            .startAt([searchKeyword]).endAt(
                                ['$searchKeyword\uf8ff']).snapshots(),
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
                          final data = msg.data() as Map<String, dynamic>;

                          final text = data['text'] ?? '';
                          final senderId = data['senderId'];
                          final isMe = senderId ==
                              FirebaseAuth.instance.currentUser?.uid;

                          final type = data['type'] ?? 'text';
                          final fileUrl = data['url'];
                          final fileName = data['fileName'];
                          final isImage = type == 'image';
                          final isFile = type == 'doc';
                          final isAudio = type == 'file' &&
                              fileName != null &&
                              fileName.endsWith(
                                  '.m4a'); // or use type == 'audio' if you separated audio

                          final List<String> seenList =
                              data.containsKey('seenBy') &&
                                      data['seenBy'] is List
                                  ? List<String>.from(data['seenBy'])
                                  : <String>[];

                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeText = timestamp != null
                              ? DateFormat('hh:mm a').format(timestamp.toDate())
                              : '';

                          return GestureDetector(
                            onTap: kIsWeb
                                ? () => _showReactionPicker(context, msg.id)
                                : null,
                            onLongPress: !kIsWeb
                                ? () => _showReactionPicker(context, msg.id)
                                : null,
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _hoveredMessageId = msg.id),
                                onExit: (_) =>
                                    setState(() => _hoveredMessageId = null),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Leading “⋮” slot (incoming)
                                    if (kIsWeb)
                                      SizedBox(
                                        width: 24,
                                        child: Opacity(
                                          opacity: (!isMe &&
                                                  _hoveredMessageId == msg.id)
                                              ? 1
                                              : 0,
                                          child: PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.more_vert,
                                                size: 16),
                                            onSelected: (v) {
                                              if (v == 'reaction')
                                                _showReactionPicker(
                                                    context, msg.id);
                                              if (v == 'edit' && isMe)
                                                _enterEditMode(msg.id, text);
                                              if (v == 'delete' && isMe)
                                                _confirmDeletion(msg.id);
                                            },
                                            itemBuilder: (_) {
                                              final items =
                                                  <PopupMenuEntry<String>>[
                                                const PopupMenuItem(
                                                    value: 'reaction',
                                                    child:
                                                        Text('Add Reaction')),
                                              ];
                                              if (isMe) {
                                                items.addAll([
                                                  const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Text('Edit')),
                                                  const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Text('Delete')),
                                                ]);
                                              }
                                              return items;
                                            },
                                          ),
                                        ),
                                      ),

                                    // Bubble + reactions
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? Colors.blue.shade100
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: isMe
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              if (isImage && fileUrl != null)
                                                _buildImageMessage(fileUrl)
                                              else if (isFile &&
                                                  fileUrl != null &&
                                                  fileName != null)
                                                _buildFileMessage(
                                                    fileName, fileUrl)
                                              else if (isAudio &&
                                                  fileUrl != null)
                                                _buildAudioMessage(fileUrl)
                                              else if (_editingMessageId ==
                                                  msg.id) ...[
                                                // Constrain the TextField to avoid unbounded width errors
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.75,
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _editControllers[
                                                            msg.id],
                                                    maxLines: null,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          _saveEdit(msg.id),
                                                      child: const Text('Save'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          _cancelEdit(msg.id),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                  ],
                                                ),
                                              ] else ...[
                                                MarkdownBody(
                                                  data: cleanMarkdown(text),
                                                  styleSheet: MarkdownStyleSheet
                                                          .fromTheme(
                                                              Theme.of(context))
                                                      .copyWith(
                                                    p: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  onTapLink:
                                                      (t, href, title) async {
                                                    if (href != null &&
                                                        await canLaunchUrl(
                                                            Uri.parse(href))) {
                                                      await launchUrl(
                                                          Uri.parse(href),
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    }
                                                  },
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        setState(() =>
                                                            _translating[
                                                                msg.id] = true);
                                                        try {
                                                          final result =
                                                              await FirebaseFunctions
                                                                  .instance
                                                                  .httpsCallable(
                                                                      'translateWithGemini')
                                                                  .call({
                                                            'text': text,
                                                            'targetLang':
                                                                'English'
                                                          });
                                                          setState(() {
                                                            _translatedMessages[
                                                                msg.id] = result
                                                                        .data[
                                                                    'reply'] ??
                                                                '⚠️ No translation';
                                                            _translating[
                                                                msg.id] = false;
                                                          });
                                                        } catch (_) {
                                                          setState(() {
                                                            _translatedMessages[
                                                                    msg.id] =
                                                                '⚠️ Error translating';
                                                            _translating[
                                                                msg.id] = false;
                                                          });
                                                        }
                                                      },
                                                      child: const Icon(
                                                          Icons.language,
                                                          size: 18),
                                                    ),
                                                    if (_translating[msg.id] ==
                                                        true)
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 8),
                                                        child: SizedBox(
                                                          height: 14,
                                                          width: 14,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (_translatedMessages[
                                                        msg.id] !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6),
                                                    child: Text(
                                                      _translatedMessages[
                                                          msg.id]!,
                                                      style: const TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                if (isMe)
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        timeText,
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        seenList.length >= 1
                                                            ? Icons.done_all
                                                            : Icons.check,
                                                        size: 14,
                                                        color:
                                                            seenList.length >= 1
                                                                ? Colors.blue
                                                                : Colors.grey,
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Text(
                                                    timeText,
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey),
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),

                                        // Reactions bubble
                                        if (data['reactions']
                                                is Map<String, dynamic> &&
                                            (data['reactions'] as Map)
                                                .isNotEmpty)
                                          Positioned(
                                            bottom: -10,
                                            right: isMe ? 0 : null,
                                            left: isMe ? null : 0,
                                            child: Builder(
                                              builder: (ctx) {
                                                final reactions =
                                                    Map<String, dynamic>.from(
                                                        data['reactions']);
                                                final Map<String, int>
                                                    emojiCounts = {};
                                                final currentUserId =
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid;
                                                final userReaction =
                                                    reactions[currentUserId];
                                                reactions.values.forEach((e) {
                                                  emojiCounts[e] =
                                                      (emojiCounts[e] ?? 0) + 1;
                                                });
                                                final Map<String, List<String>>
                                                    emojiUserMap = {};
                                                reactions.forEach((uid, e) {
                                                  emojiUserMap
                                                      .putIfAbsent(e, () => [])
                                                      .add(uid);
                                                });
                                                return Wrap(
                                                  spacing: 4,
                                                  children: emojiCounts.entries
                                                      .map((entry) {
                                                    final emoji = entry.key;
                                                    final count = entry.value;
                                                    final userIds =
                                                        emojiUserMap[emoji]!;
                                                    final isMine =
                                                        emoji == userReaction;
                                                    return FutureBuilder<
                                                        List<String>>(
                                                      future: Future.wait(
                                                          userIds
                                                              .map((uid) async {
                                                        if (uid ==
                                                            currentUserId)
                                                          return 'You';
                                                        return await _getUserName(
                                                            uid);
                                                      })),
                                                      builder: (c, snap) {
                                                        final tooltipText =
                                                            snap.hasData
                                                                ? snap.data!
                                                                    .join(', ')
                                                                : userIds
                                                                    .join(', ');
                                                        return Tooltip(
                                                          message: tooltipText,
                                                          child:
                                                              GestureDetector(
                                                            onTap: isMine
                                                                ? () => _updateReaction(
                                                                    msg.id,
                                                                    currentUserId!,
                                                                    emoji)
                                                                : null,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isMine
                                                                    ? Colors
                                                                        .blue
                                                                        .shade100
                                                                    : Colors
                                                                        .grey
                                                                        .shade300,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border: isMine
                                                                    ? Border.all(
                                                                        color: Colors
                                                                            .blue,
                                                                        width:
                                                                            1)
                                                                    : null,
                                                              ),
                                                              child: Text(
                                                                '$emoji $count',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: isMine
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                                  color: isMine
                                                                      ? Colors
                                                                          .blueAccent
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }).toList(),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Trailing “⋮” slot (outgoing)
                                    if (kIsWeb)
                                      SizedBox(
                                        width: 24,
                                        child: Opacity(
                                          opacity: (isMe &&
                                                  _hoveredMessageId == msg.id)
                                              ? 1
                                              : 0,
                                          child: PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.more_vert,
                                                size: 16),
                                            onSelected: (v) {
                                              if (v == 'reaction')
                                                _showReactionPicker(
                                                    context, msg.id);
                                              if (v == 'edit' && isMe)
                                                _enterEditMode(msg.id, text);
                                              if (v == 'delete' && isMe)
                                                _confirmDeletion(msg.id);
                                            },
                                            itemBuilder: (_) {
                                              final items =
                                                  <PopupMenuEntry<String>>[
                                                const PopupMenuItem(
                                                    value: 'reaction',
                                                    child:
                                                        Text('Add Reaction')),
                                              ];
                                              if (isMe) {
                                                items.addAll([
                                                  const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Text('Edit')),
                                                  const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Text('Delete')),
                                                ]);
                                              }
                                              return items;
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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

  Widget _buildFileMessage(String filename, String url) {
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
