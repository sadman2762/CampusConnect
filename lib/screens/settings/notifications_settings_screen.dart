import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  static const routeName = '/settings/notifications';
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications Settings')),
      body: const Center(child: Text('Notification toggles go here')),
    );
  }
}
