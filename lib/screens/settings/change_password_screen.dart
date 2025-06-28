import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  static const routeName = '/settings/change-password';
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: const Center(child: Text('Change Password UI goes here')),
    );
  }
}
