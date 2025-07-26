import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _usernameToEmail(String username) => '$username@fake.moodbites.app';

  Future<User?> authenticateUser(String username, String password) async {
    final email = _usernameToEmail(username);
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> registerUser(String username, String password) async {
    final email = _usernameToEmail(username);
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> logout() => _auth.signOut();
}
