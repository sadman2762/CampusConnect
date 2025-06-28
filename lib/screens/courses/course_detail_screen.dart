import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CourseDetailScreen extends StatefulWidget {
  static const routeName = '/course-detail';
  final String courseTitle;

  const CourseDetailScreen({
    Key? key,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  XFile? _pickedVideo;

  Future<void> _submitText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    // TODO: upload `text` to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text submitted')),
    );
    _textController.clear();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedImage = file);
      // TODO: upload image file.path
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedVideo = file);
      // TODO: upload video file.path
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildPreview() {
    if (_pickedImage != null) {
      return Image.file(File(_pickedImage!.path), height: 150);
    } else if (_pickedVideo != null) {
      return ListTile(
        leading: const Icon(Icons.videocam),
        title: Text(_pickedVideo!.name),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Material',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // --- Text upload ---
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter notes or text…',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitText,
              child: const Text('Submit Text'),
            ),
            const Divider(height: 32),

            // --- Image upload ---
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Upload Image'),
            ),
            const SizedBox(height: 8),

            // --- Video upload ---
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam_outlined),
              label: const Text('Upload Video'),
            ),

            const SizedBox(height: 16),
            _buildPreview(),
          ],
        ),
      ),
    );
  }
}
