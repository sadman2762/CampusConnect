// lib/screens/settings/privacy_settings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  static const routeName = '/settings/privacy';
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _user = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _profileVisible = true;
  bool _allowRequests = true;
  bool _shareStatus = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final doc = await _firestore.collection('users').doc(_user.uid).get();
    final data = doc.data()?['privacy'] as Map<String, dynamic>? ?? {};
    setState(() {
      _profileVisible = data['profileVisible'] as bool? ?? true;
      _allowRequests = data['allowRequests'] as bool? ?? true;
      _shareStatus = data['shareStatus'] as bool? ?? true;
      _loading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) {
    return _firestore.collection('users').doc(_user.uid).set({
      'privacy': {key: value}
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Profile Visibility'),
                  subtitle: const Text('Show my profile in directory/search'),
                  value: _profileVisible,
                  onChanged: (val) {
                    setState(() => _profileVisible = val);
                    _updateSetting('profileVisible', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Message Requests'),
                  subtitle: const Text('Allow messages from non-friends'),
                  value: _allowRequests,
                  onChanged: (val) {
                    setState(() => _allowRequests = val);
                    _updateSetting('allowRequests', val);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Share Activity Status'),
                  subtitle: const Text('Show my online/last-seen status'),
                  value: _shareStatus,
                  onChanged: (val) {
                    setState(() => _shareStatus = val);
                    _updateSetting('shareStatus', val);
                  },
                ),
                const Divider(),
              ],
            ),
    );
  }
}
