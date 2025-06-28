// lib/screens/settings/theme_settings_screen.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class ThemeSettingsScreen extends StatelessWidget {
  static const routeName = '/settings/theme';
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Theme')),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeNotifier,
        builder: (context, selectedMode, _) {
          return Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: selectedMode,
                onChanged: (mode) {
                  if (mode != null) AppTheme.themeNotifier.value = mode;
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: selectedMode,
                onChanged: (mode) {
                  if (mode != null) AppTheme.themeNotifier.value = mode;
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: selectedMode,
                onChanged: (mode) {
                  if (mode != null) AppTheme.themeNotifier.value = mode;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
