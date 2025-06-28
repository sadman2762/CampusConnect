import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase options
import 'firebase_options.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// Main
import 'screens/home/home_screen.dart';

// Courses
import 'screens/courses/courses_screen.dart';
import 'screens/courses/course_detail_screen.dart';

// Student Feed
import 'screens/student_feed/student_feed_screen.dart';

// Discussions & Queries
import 'screens/discussions/group_discussions_screen.dart';
import 'screens/queries/queries_screen.dart';

// Guidance & AI Chat
import 'screens/guidance/guidance_screen.dart';
import 'screens/guidance/guidance_chat_screen.dart';
import 'screens/ai_chat/ai_chat_screen.dart';

// Profile & Settings
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/edit_profile_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/notifications_settings_screen.dart';
import 'screens/settings/privacy_settings_screen.dart';
import 'screens/settings/theme_settings_screen.dart';

// Help
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'CampusConnect',
          debugShowCheckedModeBanner: false,

          // **Dynamic theming**
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // Show login or home screen based on auth state
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.hasData
                  ? const HomeScreen()
                  : const LoginScreen();
            },
          ),

          // Static named routes
          routes: {
            // Auth
            LoginScreen.routeName: (_) => const LoginScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),

            // Core
            HomeScreen.routeName: (_) => const HomeScreen(),
            CoursesScreen.routeName: (_) => const CoursesScreen(),
            StudentFeedScreen.routeName: (_) => StudentFeedScreen(),

            // Discussions & Queries
            QueriesScreen.routeName: (_) => const QueriesScreen(),

            // Guidance & AI
            GuidanceScreen.routeName: (_) => const GuidanceScreen(),
            AIChatScreen.routeName: (_) => const AIChatScreen(),

            // Profile & Settings
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            SettingsScreen.routeName: (_) => const SettingsScreen(),
            EditProfileScreen.routeName: (_) => const EditProfileScreen(),
            ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
            NotificationsSettingsScreen.routeName: (_) =>
                const NotificationsSettingsScreen(),
            PrivacySettingsScreen.routeName: (_) =>
                const PrivacySettingsScreen(),
            ThemeSettingsScreen.routeName: (_) => const ThemeSettingsScreen(),

            // Help
            HelpCenterScreen.routeName: (_) => const HelpCenterScreen(),
          },

          // Dynamic / argument‐based routes
          onGenerateRoute: (settings) {
            switch (settings.name) {
              // Course detail
              case CourseDetailScreen.routeName:
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                return MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(
                    courseTitle:
                        args['courseTitle'] as String? ?? 'Unknown Course',
                  ),
                );

              // Group discussions
              case GroupDiscussionsScreen.routeName:
                final gdArgs =
                    settings.arguments as Map<String, dynamic>? ?? {};
                return MaterialPageRoute(
                  builder: (_) => GroupDiscussionsScreen(
                    groupName: gdArgs['groupName'] as String? ?? 'CS23 Webtech',
                  ),
                );

              // Guidance chat
              case '/guidance_chat':
                final chatArgs =
                    settings.arguments as Map<String, dynamic>? ?? {};
                return MaterialPageRoute(
                  builder: (_) => GuidanceChatScreen(
                    peerId: chatArgs['peerId'],
                    peerName: chatArgs['peerName'],
                  ),
                );

              default:
                return null; // fall back to routes table
            }
          },

          // Global error handler
          builder: (ctx, child) {
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
      },
    );
  }
}
