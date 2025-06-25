import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart'; // ✅ Add this import

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/student_feed/student_feed_screen.dart';
import 'screens/discussions/group_discussions_screen.dart';
import 'screens/queries/queries_screen.dart';
import 'screens/guidance/guidance_screen.dart';
import 'screens/ai_chat/ai_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase using the manually created options
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
      theme: ThemeData(primarySwatch: Colors.blue),

      // Decide initial screen based on authentication state
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

      // Named routes for in-app navigation
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
      },

      // Global error widget
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Center(
            child: Text(
              'Something went wrong!\n${details.exception}',
              textAlign: TextAlign.center,
            ),
          );
        };
        return child!;
      },
    );
  }
}
