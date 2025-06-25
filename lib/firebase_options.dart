// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
        'DefaultFirebaseOptions are not supported on this platform.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDACK35Xo4ezDV-dVeqdCf7E2_msrdcP2Y",
    authDomain: "campusconnect-a8cf1.firebaseapp.com",
    projectId: "campusconnect-a8cf1",
    storageBucket: "campusconnect-a8cf1.firebasestorage.app",
    messagingSenderId: "1076807725976",
    appId: "1:1076807725976:web:14b15d575e3c1294b431ed",
    measurementId: "G-M105RSTTWQ",
  );
}
