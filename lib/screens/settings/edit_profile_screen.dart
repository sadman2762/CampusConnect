import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  User _user = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
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
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      String? photoURL;

      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profilePhotos/${_user.uid}/avatar.jpg');

        if (kIsWeb) {
          final bytes = await _pickedImage!.readAsBytes();
          await storageRef
              .putData(bytes, SettableMetadata(contentType: 'image/jpeg'))
              .timeout(const Duration(seconds: 20), onTimeout: () {
            throw Exception('Upload timed out');
          });
        } else {
          await storageRef
              .putFile(File(_pickedImage!.path))
              .timeout(const Duration(seconds: 20), onTimeout: () {
            throw Exception('Upload timed out');
          });
        }

        photoURL = await storageRef.getDownloadURL();
        await _user.updatePhotoURL(photoURL);
        await _user.reload();
        _user = FirebaseAuth.instance.currentUser!;
      }

      final newName = _nameCtrl.text.trim();
      if (newName != _user.displayName) {
        await _user.updateDisplayName(newName);
      }
      if (_emailCtrl.text.trim() != _user.email) {
        await _user.updateEmail(_emailCtrl.text.trim());
      }

      final data = {
        'name': newName, // ✅ FIX: update Firestore `name`
        'bio': _bioCtrl.text.trim(),
        'university': _univCtrl.text.trim(),
        'year': _year,
      };
      if (photoURL != null) data['profilePic'] = photoURL;

      await _firestore
          .collection('users')
          .doc(_user.uid)
          .set(data, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<ImageProvider> _getProfileImage() async {
    if (_pickedImage != null) {
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        return MemoryImage(bytes);
      } else {
        return FileImage(File(_pickedImage!.path));
      }
    } else if (_user.photoURL != null && _user.photoURL!.startsWith('http')) {
      return NetworkImage(_user.photoURL!);
    } else {
      return const AssetImage('assets/images/profile.jpg');
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
                  Center(
                    child: Stack(
                      children: [
                        FutureBuilder<ImageProvider>(
                          future: _getProfileImage(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('assets/images/profile.jpg'),
                              );
                            }
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: snapshot.data,
                            );
                          },
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
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _univCtrl,
                    decoration: const InputDecoration(
                      labelText: 'University',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
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
