// lib/screens/settings/notifications_settings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  static const routeName = '/settings/notifications';
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final _user = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _push = true;
  bool _email = true;
  bool _weekly = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final doc = await _firestore.collection('users').doc(_user.uid).get();
    final data = doc.data()?['notifications'] as Map<String, dynamic>? ?? {};
    setState(() {
      _push = data['push'] as bool? ?? true;
      _email = data['email'] as bool? ?? true;
      _weekly = data['weeklySummary'] as bool? ?? false;
      _loading = false;
    });
  }

  Future<void> _updateNotification(String key, bool value) {
    return _firestore.collection('users').doc(_user.uid).set({
      'notifications': {key: value}
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push alerts'),
                  value: _push,
                  onChanged: (val) {
                    setState(() => _push = val);
                    _updateNotification('push', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email updates'),
                  value: _email,
                  onChanged: (val) {
                    setState(() => _email = val);
                    _updateNotification('email', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Weekly Summary'),
                  subtitle: const Text('Get a weekly activity summary'),
                  value: _weekly,
                  onChanged: (val) {
                    setState(() => _weekly = val);
                    _updateNotification('weeklySummary', val);
                  },
                ),
                const Divider(),
              ],
            ),
    );
  }
}
