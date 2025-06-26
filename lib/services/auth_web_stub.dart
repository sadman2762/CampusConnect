// lib/services/auth_web_stub.dart

class UserCredential {
  final String uid;
  UserCredential(this.uid);
}

Future<UserCredential> signIn(String email, String pass) async {
  await Future.delayed(const Duration(seconds: 1));
  return UserCredential('web-fake-uid');
}

Future<UserCredential> signUp(String email, String pass) async {
  await Future.delayed(const Duration(seconds: 1));
  return UserCredential('web-fake-uid');
}
