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
import 'screens/guidance/guidance_chat_screen.dart';
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
      title: 'CampusConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Show login or home screen based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData ? const HomeScreen() : const LoginScreen();
        },
      ),

      // Named routes
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        CoursesScreen.routeName: (context) => const CoursesScreen(),
        StudentFeedScreen.routeName: (context) => StudentFeedScreen(),
        QueriesScreen.routeName: (context) => const QueriesScreen(),
        GuidanceScreen.routeName: (context) => const GuidanceScreen(),
        AIChatScreen.routeName: (context) => const AIChatScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        HelpCenterScreen.routeName: (context) => const HelpCenterScreen(),

        // New: Dynamic group discussions route (via ModalRoute)
        GroupDiscussionsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final groupName =
              (args as Map<String, dynamic>?)?['groupName'] ?? 'CS23 Webtech';
          return GroupDiscussionsScreen(groupName: groupName);
        },

        // New: Guidance Chat Route with peerId and peerName
        '/guidance_chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return GuidanceChatScreen(
            peerId: args['peerId'],
            peerName: args['peerName'],
          );
        },
      },

      // Error fallback
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Text(
                'Something went wrong!\n${details.exceptionAsString()}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
