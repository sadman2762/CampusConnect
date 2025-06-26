import 'package:flutter/material.dart';
import '../../theme/theme.dart'; // Ensure AppColors is defined here

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const routeName = '/help-center';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('4TY Help Centre'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/4ty_logo.jpg',
                height: 100,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Welcome to 4TY Help Centre',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '4TY is a generative self-learning AI designed to support students at the University of Debrecen (UNIDEB). It continuously improves by learning from student questions, official academic resources, and university guidelines.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Our goal is to provide on-demand, intelligent help for everything from assignments and coding to exam prep and university services. 4TY is available 24/7 and always gets smarter with each interaction.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Created by students, for students, 4TY empowers the UNIDEB community to learn faster, solve problems independently, and stay academically informed.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text(
              'Need help or feedback?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: sadman@mailbox.unideb.hu'),
                  Text('WhatsApp: +36 20 298 9512'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2025 4TY — All rights reserved',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
