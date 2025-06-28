import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/theme.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/settings/edit-profile';

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _picker = ImagePicker();
  XFile? _pickedImage;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _univCtrl = TextEditingController();
  String _year = '1';

  final _user = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // prefill from auth & Firestore
    _nameCtrl.text = _user.displayName ?? '';
    _emailCtrl.text = _user.email ?? '';
    _firestore.collection('users').doc(_user.uid).get().then((snap) {
      if (snap.exists) {
        final data = snap.data()!;
        _bioCtrl.text = data['bio'] ?? '';
        _univCtrl.text = data['university'] ?? '';
        setState(() => _year = (data['year'] ?? '1').toString());
      }
    });
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      // 1) Upload avatar to Storage & get URL (omitted here)
      //    final photoURL = await uploadToStorage(_pickedImage);

      final updates = <String, dynamic>{};
      if (_pickedImage != null) {
        // Example: upload logic replaced by local file path for demo
        final photoURL = _pickedImage!.path;
        updates['photoURL'] = photoURL;
        await _user.updatePhotoURL(photoURL);
      }

      if (_nameCtrl.text.trim() != _user.displayName) {
        updates['displayName'] = _nameCtrl.text.trim();
        await _user.updateDisplayName(_nameCtrl.text.trim());
      }
      if (_emailCtrl.text.trim() != _user.email) {
        await _user.updateEmail(_emailCtrl.text.trim());
      }

      // 2) Firestore update:
      await _firestore.collection('users').doc(_user.uid).set({
        'bio': _bioCtrl.text.trim(),
        'university': _univCtrl.text.trim(),
        'year': _year,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _univCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedImage != null
                              ? FileImage(File(_pickedImage!.path))
                              : (_user.photoURL != null
                                  ? NetworkImage(_user.photoURL!)
                                  : const AssetImage(
                                          'assets/images/profile.jpg')
                                      as ImageProvider),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: InkWell(
                            onTap: _pickAvatar,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // University
                  TextField(
                    controller: _univCtrl,
                    decoration: const InputDecoration(
                      labelText: 'University',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Year dropdown
                  DropdownButtonFormField<String>(
                    value: _year,
                    items: ['1', '2', '3', '4', '5']
                        .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y${_ordinal(y)} year'),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Year of Study',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _year = v!),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }

  String _ordinal(String y) {
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
}
