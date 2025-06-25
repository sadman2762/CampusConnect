// lib/services/auth_web.dart

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCredential {
  final String uid;
  final String email;
  UserCredential(this.uid, this.email);
}

Future<UserCredential> signIn(String email, String pass) async {
  final fa.UserCredential cred =
      await fa.FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: pass,
  );
  final user = cred.user!;
  return UserCredential(user.uid, user.email!);
}

Future<UserCredential> signUp(String email, String pass) async {
  final fa.UserCredential cred =
      await fa.FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: pass,
  );
  final user = cred.user!;
  // write your Firestore document
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'email': user.email,
    'createdAt': FieldValue.serverTimestamp(),
  });
  return UserCredential(user.uid, user.email!);
}
