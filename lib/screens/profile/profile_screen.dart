import 'package:flutter/material.dart';
import '../../theme/theme.dart'; // ✅ Import AppColors

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Header with Gradient
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/images/profile.jpg'), // Replace with real path
                ),
                const SizedBox(height: 10),
                Text(
                  "Samantha Jones",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  "New York, United States",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Web Producer - Web Specialist",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "Columbia University - New York",
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 24),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatCard(label: "Friends", value: "65"),
                _StatCard(label: "Photos", value: "43"),
                _StatCard(label: "Comments", value: "21"),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Show More Button
          ElevatedButton(
            onPressed: () {},
            child: const Text("Show more"),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
