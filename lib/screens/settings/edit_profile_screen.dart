import 'dart:io';
import 'dart:async';
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
  double _uploadProgress = 0.0;

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
    if (file != null) {
      setState(() => _pickedImage = file);
      print('Debug: Avatar picked at path: ${file.path}'); // Added debug log
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
      _uploadProgress = 0.0;
    });

    print('Debug: _saveProfile called'); // Added debug log
    print(
        'Debug: Current pickedImage: $_pickedImage'); // Added debug log to check if image is set

    try {
      String? photoURL;

      if (_pickedImage != null) {
        print('Picked image: ${_pickedImage!.path}');
        print('User UID: ${_user.uid}');

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatars/${_user.uid}.jpg');

        print('Uploading to: user_avatars/${_user.uid}.jpg');

        try {
          if (kIsWeb) {
            final bytes = await _pickedImage!.readAsBytes();

            if (bytes.length > 3000 * 1024) {
              throw Exception(
                  'Image too large. Please use an image under 500 KB.');
            }

            final uploadTask = storageRef.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );

            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
              final progress = snapshot.bytesTransferred / snapshot.totalBytes;
              setState(() {
                _uploadProgress = progress;
              });
            });

            await uploadTask; // removed timeout wrapper to surface actual errors during upload
          } else {
            final file = File(_pickedImage!.path);
            final uploadTask = storageRef.putFile(file);

            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
              final progress = snapshot.bytesTransferred / snapshot.totalBytes;
              setState(() {
                _uploadProgress = progress;
              });
            });

            await uploadTask.timeout(
              const Duration(minutes: 2),
              onTimeout: () => throw TimeoutException('Upload took too long'),
            );
          }
        } catch (uploadError) {
          print('Upload error: $uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $uploadError')),
          );
          throw Exception('Upload failed: $uploadError');
        }

        final downloadUrl = await storageRef.getDownloadURL();
        photoURL = '$downloadUrl?t=${DateTime.now().millisecondsSinceEpoch}';

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
        'name': newName,
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
      print('Save profile error: $e');
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
                  if (_uploadProgress > 0 && _uploadProgress < 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(value: _uploadProgress),
                    ),
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
