// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return ios;
    }
    throw UnsupportedError(
        'DefaultFirebaseOptions are not supported on this platform.');
  }

  // Web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDACK35Xo4ezDV-dVeqdCf7E2_msrdcP2Y",
    authDomain: "campusconnect-a8cf1.firebaseapp.com",
    projectId: "campusconnect-a8cf1",
    storageBucket: "campusconnect-a8cf1.firebasestorage.app", // ← corrected
    messagingSenderId: "1076807725976",
    appId: "1:1076807725976:web:14b15d575e3c1294b431ed",
    measurementId: "G-M105RSTTWQ",
  );

  // Stub Android config (replace these with your real values)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YOUR_ANDROID_API_KEY",
    appId: "YOUR_ANDROID_APP_ID",
    messagingSenderId: "YOUR_ANDROID_SENDER_ID",
    projectId: "campusconnect-a8cf1",
    storageBucket: "campusconnect-a8cf1.appspot.com",
  );

  // Stub iOS config (replace these with your real values)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "YOUR_IOS_SENDER_ID",
    projectId: "campusconnect-a8cf1",
    storageBucket: "campusconnect-a8cf1.appspot.com",
    iosBundleId: "com.yourcompany.campusconnect",
  );
}
