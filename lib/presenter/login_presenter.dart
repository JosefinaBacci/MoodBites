import '../model/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPresenter {
  final AuthModel _auth = AuthModel();

  Future<User?> login(String email, String pass) =>
      _auth.authenticateUser(email, pass);

  Future<User?> register(String email, String pass) =>
      _auth.registerUser(email, pass);

  void logout() => _auth.logout();

  User? currentUser() => _auth.getCurrentUser();
}
