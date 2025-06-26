import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase options
import 'firebase_options.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/student_feed/student_feed_screen.dart';
import 'screens/discussions/group_discussions_screen.dart';
import 'screens/queries/queries_screen.dart';
import 'screens/guidance/guidance_screen.dart';
import 'screens/ai_chat/ai_chat_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/help/help_center_screen.dart';

// Theme
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Initial screen based on Firebase Auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),

      // Named routes for navigation
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        CoursesScreen.routeName: (_) => const CoursesScreen(),
        StudentFeedScreen.routeName: (_) => StudentFeedScreen(),
        GroupDiscussionsScreen.routeName: (_) => GroupDiscussionsScreen(),
        QueriesScreen.routeName: (_) => const QueriesScreen(),
        GuidanceScreen.routeName: (_) => const GuidanceScreen(),
        AIChatScreen.routeName: (_) => const AIChatScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        HelpCenterScreen.routeName: (_) => const HelpCenterScreen(),
      },

      // Global error handler
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Text(
                'Something went wrong!\n${details.exception}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
