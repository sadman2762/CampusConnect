import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatelessWidget {
  static const routeName = '/settings/theme';
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Theme')),
      body: const Center(child: Text('Theme selector goes here')),
    );
  }
}
