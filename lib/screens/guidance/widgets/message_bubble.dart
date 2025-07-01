import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final Future<String> Function(String) onTranslate;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onTranslate,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String? _translatedText;
  bool _loading = false;

  void _handleTranslate() async {
    setState(() => _loading = true);
    final translated = await widget.onTranslate(widget.message);
    setState(() {
      _translatedText = translated;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _loading ? null : _handleTranslate,
                  child: const Icon(Icons.language, size: 18),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
              ],
            ),
            if (_translatedText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _translatedText!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
