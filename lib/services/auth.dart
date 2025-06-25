// lib/services/auth.dart
// AFTER
export 'auth_web.dart' if (dart.library.io) 'auth_mobile.dart';
