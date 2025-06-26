// lib/screens/courses/courses_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
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

  final List<String> _updates = [
    'Dates of HLP-L0 exams announced next month.',
    'HLP-L1 syllabus updated—check new topics.',
    'HLP-L2 practice quiz posted.',
    'HLP-L3 sample paper released.',
    'Lab sessions canceled this Friday.',
    'Guest lecture scheduled on Monday.',
    'Course feedback form is now open.',
  ];

  final List<Map<String, dynamic>> _topCourses = [
    {'title': 'Data Structures', 'rating': 9.5},
    {'title': 'Algorithms', 'rating': 9.2},
    {'title': 'Software Engineering', 'rating': 9.0},
    {'title': 'Applied Statistics', 'rating': 8.7},
    {'title': 'Web Technologies', 'rating': 8.4},
    {'title': 'Intro to CS', 'rating': 8.0},
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

  void _openRanking() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
                onPressed: () => Navigator.pushReplacementNamed(
                    context, HomeScreen.routeName),
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
                onPressed: () => Navigator.pushReplacementNamed(
                    context, ProfileScreen.routeName),
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
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
                  'Explore a variety of courses with detailed information on topics, exam patterns, and more to enhance your academic journey.',
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

                SizedBox(
                  height: height * 0.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: _updates.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, i) => UpdateItem(text: _updates[i]),
                      ),
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
