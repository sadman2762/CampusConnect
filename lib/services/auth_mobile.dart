// lib/services/auth_mobile.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<UserCredential> signIn(String email, String pass) {
  return FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: pass);
}

Future<UserCredential> signUp(String email, String pass) async {
  // 1) Create user
  final cred = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: pass);

  // 2) Write a profile in Firestore
  await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
    'email': email,
    'createdAt': FieldValue.serverTimestamp(),
  });

  return cred;
}
