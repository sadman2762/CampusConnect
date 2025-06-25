// lib/screens/courses/courses_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'widgets/course_card.dart';
import 'widgets/update_item.dart';

class CoursesScreen extends StatefulWidget {
  static const routeName = '/courses';
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  late final TabController _tabController;
  late final ScrollController _scrollController;

  // 8 courses now
  final List<Map<String, String>> _courses = [
    {
      'title': 'Introduction to Programming',
      'image': 'assets/images/courses.jpg',
    },
    {
      'title': 'High-Level Programming Languages',
      'image': 'assets/images/profiles.jpg',
    },
    {'title': 'Databases 101', 'image': 'assets/images/discussions.jpg'},
    {'title': 'HLP-L3 Exams', 'image': 'assets/images/guidance.jpg'},
    {'title': 'Web Technologies', 'image': 'assets/images/queries.jpg'},
    {'title': 'Introduction to CS', 'image': 'assets/images/courses.jpg'},
    {'title': 'Applied Statistics', 'image': 'assets/images/profiles.jpg'},
    {'title': 'Software Engineering', 'image': 'assets/images/discussions.jpg'},
  ];

  // 7 notifications
  final List<String> _updates = [
    'Dates of HLP-L0 exams announced next month.',
    'HLP-L1 syllabus updated—check new topics.',
    'HLP-L2 practice quiz posted.',
    'HLP-L3 sample paper released.',
    'Lab sessions canceled this Friday.',
    'Guest lecture scheduled on Monday.',
    'Course feedback form is now open.',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _openRanking() => _scaffoldKey.currentState?.openEndDrawer();
  void _goToNotifications() => _tabController.animateTo(1);

  void _scrollToSearch() {
    if (_searchKey.currentContext != null) {
      Scrollable.ensureVisible(
        _searchKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // Left drawer (profile)
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade100),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/profiles.jpg'),
                  ),
                  SizedBox(width: 16),
                  Text('John Doe\njohndoe@example.com'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('My Inbox'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help Center'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '© 2025 4TY',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),

      // Right drawer (ranking)
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Subject Rankings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      title: Text('Data Structures'),
                      trailing: Text('9.5'),
                    ),
                    ListTile(title: Text('Algorithms'), trailing: Text('9.2')),
                    ListTile(
                      title: Text('Software Engineering'),
                      trailing: Text('9.0'),
                    ),
                    ListTile(
                      title: Text('Applied Statistics'),
                      trailing: Text('8.7'),
                    ),
                    ListTile(
                      title: Text('Web Technologies'),
                      trailing: Text('8.4'),
                    ),
                    ListTile(title: Text('Intro to CS'), trailing: Text('8.0')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Shared FAB + footer
      floatingActionButton: CustomBottomNav.fab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _goToNotifications,
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined),
                onPressed: _openRanking,
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: _openDrawer,
              ),
            ],
          ),
        ),
      ),

      // Main content
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Courses',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore a variety of courses with detailed information on topics, '
                  'exam patterns, and more to enhance your academic journey.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Search field
                Container(
                  key: _searchKey,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for Courses',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal courses
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _courses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      final c = _courses[i];
                      return CourseCard(
                        title: c['title']!,
                        imagePath: c['image']!,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(text: 'Updates'),
                    Tab(text: 'Notifications'),
                  ],
                ),
                const SizedBox(height: 8),

                // Tab views
                SizedBox(
                  height: height * 0.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Updates tab
                      ListView.separated(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: _updates.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) => UpdateItem(text: _updates[i]),
                      ),

                      // Notifications tab
                      ListView.separated(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: _updates.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) => UpdateItem(text: _updates[i]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
