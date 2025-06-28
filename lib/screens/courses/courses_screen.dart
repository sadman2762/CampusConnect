// lib/screens/courses/courses_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'course_detail_screen.dart';
import 'widgets/course_card.dart';

class CoursesScreen extends StatefulWidget {
  static const routeName = '/courses';
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // --- Data for the three course categories ---
  final List<Map<String, String>> _mathAndCs = [
    {
      'title': 'Logic in Computer Science',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Discrete Mathematics', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Computer Aided Math & Visualization',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Data Structures & Algorithms',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Calculus', 'image': 'assets/images/courses.jpg'},
    {'title': 'Applied Statistics', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Introduction to Computer Science',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Applied Mathematics', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Foundations of Artificial Intelligence',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Foundations of Computer Security',
      'image': 'assets/images/courses.jpg'
    },
  ];

  final List<Map<String, String>> _informaticsCompulsory = [
    {
      'title': 'Introduction to Programming',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Operating Systems', 'image': 'assets/images/courses.jpg'},
    {'title': 'Database Systems', 'image': 'assets/images/courses.jpg'},
    {'title': 'Database Systems Lab', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Network Architectures & Protocols',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'High‐Level Programming Languages 1',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'High-Level Programming Languages 2',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Web Technologies', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Software Engineering & Technologies',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Software Development Methodologies',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Web Application Development',
      'image': 'assets/images/courses.jpg'
    },
  ];

  final List<Map<String, String>> _informaticsDifferentiated = [
    {'title': '3D Printing & Modeling', 'image': 'assets/images/courses.jpg'},
    {'title': 'Cloud Computing', 'image': 'assets/images/courses.jpg'},
    {'title': 'Basics of GIS', 'image': 'assets/images/courses.jpg'},
    {'title': 'Bioinformatics', 'image': 'assets/images/courses.jpg'},
    {'title': 'E-Sport', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Operation of Infocom Systems',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Image Processing in Practice',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'High-Level Programming Languages 3',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Scripting Languages', 'image': 'assets/images/courses.jpg'},
    {'title': 'Intro to 3D Game Dev', 'image': 'assets/images/courses.jpg'},
    {'title': 'Compilers', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Machine Learning in Practice',
      'image': 'assets/images/courses.jpg'
    },
    {
      'title': 'Advanced Database Knowledge',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'NoSQL Databases', 'image': 'assets/images/courses.jpg'},
    {'title': 'Info & Coding Theory', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Mobile Application Development',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Computer Statistics', 'image': 'assets/images/courses.jpg'},
    {'title': 'Software Testing', 'image': 'assets/images/courses.jpg'},
    {'title': 'Advanced Data Security', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Advanced Web Technologies',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Blockchain Technology', 'image': 'assets/images/courses.jpg'},
    {
      'title': 'Intro to Reinforcement Learning',
      'image': 'assets/images/courses.jpg'
    },
    {'title': 'Professional Training', 'image': 'assets/images/courses.jpg'},
  ];

  // --- Data for Top-Ranked sidebar ---
  final List<Map<String, dynamic>> _topCourses = [
    {'title': 'Data Structures', 'rating': 9.5},
    {'title': 'Algorithms', 'rating': 9.2},
    {'title': 'Software Engineering', 'rating': 9.0},
    {'title': 'Applied Statistics', 'rating': 8.7},
    {'title': 'Web Technologies', 'rating': 8.4},
    {'title': 'Intro to CS', 'rating': 8.0},
  ];

  // --- Data for Notifications sidebar ---
  final List<String> _notifications = [
    'Dates of HLP-L0 exams announced next month.',
    'HLP-L1 syllabus updated—check new topics.',
    'HLP-L2 practice quiz posted.',
    'HLP-L3 sample paper released.',
    'Lab sessions canceled this Friday.',
    'Guest lecture scheduled on Monday.',
    'Course feedback form is now open.',
  ];

  void _openNotifications() => _scaffoldKey.currentState?.openDrawer();
  void _openRanking() => _scaffoldKey.currentState?.openEndDrawer();

  Widget _buildSection(String title, List<Map<String, String>> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final course = list[i];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => CourseDetailScreen(
                        courseTitle: course['title']!,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: CourseCard(
                  title: course['title']!,
                  imagePath: course['image']!,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // Left drawer → Notifications
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(_notifications[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Right drawer → Top-Ranked Courses
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Top Ranked Courses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _topCourses.length,
                    itemBuilder: (ctx, i) {
                      final c = _topCourses[i];
                      return ListTile(
                        title: Text(c['title']),
                        trailing: Text('${c['rating']}/10'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      backgroundColor: Colors.white,
      floatingActionButton: CustomBottomNav.fab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  HomeScreen.routeName,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _openNotifications,
              ),
              const SizedBox(width: 48), // space for FAB
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: _openRanking,
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  ProfileScreen.routeName,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Centered title
              Center(
                child: Text(
                  'Courses',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // Three sections
              _buildSection('Mathematics & Computer Science', _mathAndCs),
              _buildSection(
                'Informatics (Compulsory Topics)',
                _informaticsCompulsory,
              ),
              _buildSection(
                'Informatics (Differentiated Knowledge)',
                _informaticsDifferentiated,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
