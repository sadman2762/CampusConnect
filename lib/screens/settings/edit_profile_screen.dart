import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  static const routeName = '/settings/edit-profile';
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile UI goes here')),
    );
  }
}
