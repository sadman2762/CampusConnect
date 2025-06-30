import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notifications_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'sadman';
    final email = user?.email ?? 'sadman@maillbox.unid.com';
    final photo = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: photo != null
                        ? NetworkImage(photo)
                        : const AssetImage('assets/images/user.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Options
            SettingsTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () =>
                  Navigator.pushNamed(context, EditProfileScreen.routeName),
            ),
            SettingsTile(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () =>
                  Navigator.pushNamed(context, ChangePasswordScreen.routeName),
            ),
            SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () => Navigator.pushNamed(
                  context, NotificationsSettingsScreen.routeName),
            ),
            SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              onTap: () =>
                  Navigator.pushNamed(context, PrivacySettingsScreen.routeName),
            ),
            SettingsTile(
              icon: Icons.color_lens,
              title: 'App Theme',
              onTap: () =>
                  Navigator.pushNamed(context, ThemeSettingsScreen.routeName),
            ),

            const SizedBox(height: 48),

            // Footer Text
            Text(
              '© 4TY 2025 - all rights reserved',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
