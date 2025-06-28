import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  static const routeName = '/settings/privacy';
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: const Center(child: Text('Privacy controls go here')),
    );
  }
}
